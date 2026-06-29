using BankE.Application.Common;
using BankE.Application.DTOs;
using BankE.Application.Interfaces;
using BankE.Domain.Entities;
using BankE.Domain.Interfaces;

namespace BankE.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IJwtProvider _jwtProvider;
        public AuthService(IUnitOfWork unitOfWork, IJwtProvider jwtProvider)
        {
            _unitOfWork = unitOfWork;
            _jwtProvider = jwtProvider;
        }

        public async Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request)
        {
            if (!IsStrongPassword(request.Password))
                return ApiResponse<AuthResponse>.Fail("Password must be at least 8 characters long and contain an uppercase letter, a number, and a special character.");

            if (await _unitOfWork.Users.GetByEmailAsync(request.Email) != null)
                return ApiResponse<AuthResponse>.Fail("Email already exists");

            var refreshToken = _jwtProvider.GenerateRefreshToken();
            var user = new User
            {
                FullName = request.FullName,
                Email = request.Email,
                PhoneNumber = request.PhoneNumber,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Role = "User",
                RefreshToken = refreshToken,
                RefreshTokenExpiry = DateTime.UtcNow.AddDays(7),
                CreatedAt = DateTime.UtcNow
            };

            await _unitOfWork.Users.AddAsync(user);
            await _unitOfWork.SaveChangesAsync();

            // Create account
            var account = new Account
            {
                UserId = user.Id,
                AccountNumber = new Random().Next(10000000, 99999999).ToString(),
                Balance = 0,
                CreatedAt = DateTime.UtcNow
            };
            await _unitOfWork.Accounts.AddAsync(account);
            await _unitOfWork.SaveChangesAsync();

            var token = _jwtProvider.GenerateAccessToken(user);
            return ApiResponse<AuthResponse>.Ok(new AuthResponse(token, "Registration successful", refreshToken));
        }

        public async Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request)
        {
            var user = await _unitOfWork.Users.GetByEmailAsync(request.Email)
                       ?? await _unitOfWork.Users.GetByPhoneAsync(request.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                return ApiResponse<AuthResponse>.Fail("Invalid credentials");

            if (!user.IsActive) return ApiResponse<AuthResponse>.Fail("Account is deactivated");

            var token = _jwtProvider.GenerateAccessToken(user);
            var refreshToken = _jwtProvider.GenerateRefreshToken();
            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiry = DateTime.UtcNow.AddDays(7);
            _unitOfWork.Users.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<AuthResponse>.Ok(new AuthResponse(token, "Login successful", refreshToken));
        }

        public async Task<ApiResponse<AuthResponse>> VerifyOtpAsync(VerifyOtpRequest request)
        {
            var user = await _unitOfWork.Users.GetByEmailAsync(request.Email)
                       ?? await _unitOfWork.Users.GetByPhoneAsync(request.Email);
            if (user == null) return ApiResponse<AuthResponse>.Fail("User not found");

            if (user.OtpCode == null || user.OtpExpiry == null || user.OtpExpiry < DateTime.UtcNow)
            {
                return ApiResponse<AuthResponse>.Fail("OTP has expired or has not been requested.");
            }

            if (user.OtpAttempts >= 3)
            {
                return ApiResponse<AuthResponse>.Fail("Too many failed attempts. Please request a new OTP.");
            }

            if (user.OtpCode != request.OtpCode)
            {
                user.OtpAttempts++;
                await _unitOfWork.SaveChangesAsync();
                return ApiResponse<AuthResponse>.Fail($"Invalid OTP code. {3 - user.OtpAttempts} attempts remaining.");
            }

            // Success: clear OTP details
            user.OtpCode = null;
            user.OtpExpiry = null;
            user.OtpAttempts = 0;

            var token = _jwtProvider.GenerateAccessToken(user);
            var refreshToken = _jwtProvider.GenerateRefreshToken();
            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiry = DateTime.UtcNow.AddDays(7);
            _unitOfWork.Users.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<AuthResponse>.Ok(new AuthResponse(token, "Verified", refreshToken));
        }

        public async Task<ApiResponse<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request)
        {
            var users = await _unitOfWork.Users.FindAsync(u => u.RefreshToken == request.RefreshToken);
            var user = users.FirstOrDefault();
            if (user == null || user.RefreshTokenExpiry < DateTime.UtcNow)
            {
                return ApiResponse<AuthResponse>.Fail("Invalid or expired refresh token");
            }

            var newAccessToken = _jwtProvider.GenerateAccessToken(user);
            var newRefreshToken = _jwtProvider.GenerateRefreshToken();

            user.RefreshToken = newRefreshToken;
            user.RefreshTokenExpiry = DateTime.UtcNow.AddDays(7);
            _unitOfWork.Users.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<AuthResponse>.Ok(new AuthResponse(newAccessToken, "Token refreshed successfully", newRefreshToken));
        }

        public async Task<ApiResponse> ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            var user = await _unitOfWork.Users.GetByEmailAsync(request.Email)
                       ?? await _unitOfWork.Users.GetByPhoneAsync(request.Email);
            if (user == null) return ApiResponse.Fail("User not found");

            var random = new Random();
            var otp = random.Next(100000, 999999).ToString();
            user.OtpCode = otp;
            user.OtpExpiry = DateTime.UtcNow.AddMinutes(5);
            user.OtpAttempts = 0;

            _unitOfWork.Users.Update(user);
            await _unitOfWork.SaveChangesAsync();

            Console.WriteLine($"[OTP GENERATED] User: {user.Email}, OTP: {otp}");

            return ApiResponse.Ok("OTP sent to your email");
        }

        public async Task<ApiResponse> ResetPasswordAsync(ResetPasswordRequest request)
        {
            if (!IsStrongPassword(request.NewPassword))
                return ApiResponse.Fail("Password must be at least 8 characters long and contain an uppercase letter, a number, and a special character.");

            var user = await _unitOfWork.Users.GetByEmailAsync(request.Email)
                       ?? await _unitOfWork.Users.GetByPhoneAsync(request.Email);
            if (user == null) return ApiResponse.Fail("User not found");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            await _unitOfWork.SaveChangesAsync();
            return ApiResponse.Ok("Password reset successfully");
        }

        private bool IsStrongPassword(string password)
        {
            if (string.IsNullOrWhiteSpace(password) || password.Length < 8) return false;
            if (!password.Any(char.IsUpper)) return false;
            if (!password.Any(char.IsDigit)) return false;
            if (!password.Any(c => !char.IsLetterOrDigit(c))) return false;
            return true;
        }
    }
}
