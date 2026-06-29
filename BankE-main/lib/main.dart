import 'package:contr_project/Presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contr_project/Presentation/bloc/account_bloc.dart';
import 'package:contr_project/Presentation/bloc/transaction_bloc.dart';
import 'package:contr_project/Presentation/bloc/transfer_bloc.dart';
import 'package:contr_project/Presentation/bloc/auth_bloc.dart';
import 'package:contr_project/Presentation/bloc/notification/notification_bloc.dart';
import 'package:contr_project/Presentation/Views/auth/splash_screen.dart';
import 'package:contr_project/data/datasources/remote_account_data_source.dart';
import 'package:contr_project/data/repositories/account_repository_impl.dart';
import 'package:contr_project/domain/usecases/get_balance.dart';
import 'package:contr_project/domain/usecases/get_transactions.dart';
import 'package:contr_project/domain/usecases/get_statement.dart';
import 'package:contr_project/domain/usecases/perform_transfer.dart';
import 'package:contr_project/domain/usecases/pay_bill.dart';
import 'package:contr_project/domain/usecases/atm_transaction.dart';
import 'package:contr_project/domain/usecases/get_billers.dart';
import 'package:contr_project/core/theme/app_theme.dart';
import 'package:contr_project/domain/repositories/otp_repository.dart';
import 'package:contr_project/data/repositories/api_otp_repository_impl.dart';
import 'package:contr_project/Presentation/bloc/otp/otp_bloc.dart';
import 'package:contr_project/Presentation/bloc/admin/admin_bloc.dart';
import 'package:contr_project/Presentation/bloc/loan/loan_bloc.dart';
import 'package:contr_project/domain/repositories/card_repository.dart';
import 'package:contr_project/data/repositories/card_repository_impl.dart';
import 'package:contr_project/domain/usecases/add_card.dart';
import 'package:contr_project/domain/usecases/get_cards.dart';
import 'package:contr_project/domain/usecases/freeze_card.dart';
import 'package:contr_project/domain/usecases/delete_card.dart';
import 'package:contr_project/domain/usecases/update_card_controls.dart';
import 'package:contr_project/domain/usecases/change_card_pin.dart';
import 'package:contr_project/domain/repositories/scheduled_transfer_repository.dart';
import 'package:contr_project/data/repositories/scheduled_transfer_repository_impl.dart';
import 'package:contr_project/domain/usecases/get_scheduled_transfers.dart';
import 'package:contr_project/domain/usecases/create_scheduled_transfer.dart';
import 'package:contr_project/domain/usecases/cancel_scheduled_transfer.dart';
import 'package:contr_project/Presentation/bloc/scheduled_transfer/scheduled_transfer_bloc.dart';

import 'package:contr_project/domain/repositories/budget_repository.dart';
import 'package:contr_project/data/repositories/budget_repository_impl.dart';
import 'package:contr_project/domain/usecases/get_budgets.dart';
import 'package:contr_project/domain/usecases/create_budget.dart';
import 'package:contr_project/domain/usecases/get_budget_progress.dart';
import 'package:contr_project/domain/usecases/update_budget.dart';
import 'package:contr_project/domain/usecases/delete_budget.dart';
import 'package:contr_project/Presentation/bloc/budget/budget_bloc.dart';

import 'package:contr_project/domain/repositories/saving_goals_repository.dart';
import 'package:contr_project/data/repositories/saving_goals_repository_impl.dart';
import 'package:contr_project/domain/usecases/get_saving_goals.dart';
import 'package:contr_project/domain/usecases/create_saving_goal.dart';
import 'package:contr_project/domain/usecases/add_saving_goal_funds.dart';
import 'package:contr_project/domain/usecases/withdraw_saving_goal_funds.dart';
import 'package:contr_project/domain/usecases/update_saving_goal.dart';
import 'package:contr_project/domain/usecases/delete_saving_goal.dart';
import 'package:contr_project/Presentation/bloc/saving_goal/saving_goal_bloc.dart';

import 'package:contr_project/domain/repositories/search_repository.dart';
import 'package:contr_project/data/repositories/search_repository_impl.dart';
import 'package:contr_project/domain/usecases/global_search.dart';
import 'package:contr_project/Presentation/bloc/search/search_bloc.dart';
import 'package:contr_project/Presentation/bloc/card/card_bloc.dart';
import 'package:contr_project/domain/usecases/detect_fraud.dart';
import 'package:contr_project/Presentation/bloc/language/language_bloc.dart';
import 'package:contr_project/Presentation/bloc/theme/theme_bloc.dart';
import 'package:contr_project/Presentation/bloc/support/support_bloc.dart';
import 'package:contr_project/data/repositories/mock_support_repository_impl.dart';
import 'package:contr_project/domain/usecases/send_message.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:contr_project/l10n/app_localizations.dart';
import 'package:contr_project/data/services/mock_location_service_impl.dart';
import 'package:contr_project/core/api/api_client.dart';
import 'package:contr_project/core/api/auth_service.dart';
import 'package:contr_project/core/api/other_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // API Dependencies
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final accountService = AccountService(apiClient);
  final transferService = TransferService(apiClient);
  final atmService = AtmService(apiClient);
  final billsService = BillsService(apiClient);
  final cardsService = CardsService(apiClient);
  final loansService = LoansService(apiClient);
  final adminService = AdminService(apiClient);
  final beneficiariesService = BeneficiariesService(apiClient);
  final notificationsService = NotificationsService(apiClient);
  final usersService = UsersService(apiClient);

  final dataSource = RemoteAccountDataSourceImpl(
    apiClient: apiClient,
    authService: authService,
    accountService: accountService,
    transferService: transferService,
    atmService: atmService,
    billsService: billsService,
    cardsService: cardsService,
    loansService: loansService,
    adminService: adminService,
    beneficiariesService: beneficiariesService,
    notificationsService: notificationsService,
    usersService: usersService,
  );

  await dataSource.init();

  final accountRepository = AccountRepositoryImpl(dataSource: dataSource);
  final otpRepository = ApiOtpRepositoryImpl(authService: authService);
  final cardRepository = CardRepositoryImpl(dataSource: dataSource);
  final supportRepository = MockSupportRepositoryImpl();
  final locationService = MockLocationServiceImpl();

  final scheduledTransferRepository = ScheduledTransferRepositoryImpl(
    service: ScheduledTransfersService(apiClient),
    apiClient: apiClient,
  );
  final budgetRepository = BudgetRepositoryImpl(
    service: BudgetService(apiClient),
    apiClient: apiClient,
  );
  final savingGoalsRepository = SavingGoalsRepositoryImpl(
    service: SavingGoalsService(apiClient),
    apiClient: apiClient,
  );
  final searchRepository = SearchRepositoryImpl(
    service: SearchService(apiClient),
    apiClient: apiClient,
  );

  runApp(MyApp(
    apiClient: apiClient,
    accountRepository: accountRepository,
    otpRepository: otpRepository,
    cardRepository: cardRepository,
    supportRepository: supportRepository,
    locationService: locationService,
    dataSource: dataSource,
    authService: authService,
    usersService: usersService,
    scheduledTransferRepository: scheduledTransferRepository,
    budgetRepository: budgetRepository,
    savingGoalsRepository: savingGoalsRepository,
    searchRepository: searchRepository,
  ));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AccountRepositoryImpl accountRepository;
  final OtpRepository otpRepository;
  final CardRepository cardRepository;
  final MockSupportRepositoryImpl supportRepository;
  final MockLocationServiceImpl locationService;
  final RemoteAccountDataSourceImpl dataSource;
  final AuthService authService;
  final UsersService usersService;
  final ScheduledTransferRepository scheduledTransferRepository;
  final BudgetRepository budgetRepository;
  final SavingGoalsRepository savingGoalsRepository;
  final SearchRepository searchRepository;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.accountRepository,
    required this.otpRepository,
    required this.cardRepository,
    required this.supportRepository,
    required this.locationService,
    required this.dataSource,
    required this.authService,
    required this.usersService,
    required this.scheduledTransferRepository,
    required this.budgetRepository,
    required this.savingGoalsRepository,
    required this.searchRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AccountBloc(
            getBalanceUseCase: GetBalanceUseCase(accountRepository),
          ),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            getTransactionsUseCase: GetTransactionsUseCase(accountRepository),
            getStatementUseCase: GetStatementUseCase(accountRepository),
          ),
        ),
        BlocProvider(
          create: (context) => TransferBloc(
            performTransferUseCase: PerformTransferUseCase(accountRepository),
            payBillUseCase: PayBillUseCase(accountRepository),
            getBillersUseCase: GetBillersUseCase(accountRepository),
            detectFraudUseCase:
                DetectFraudUseCase(accountRepository, locationService),
            atmTransactionUseCase: AtmTransactionUseCase(accountRepository),
            transactionBloc: context.read<TransactionBloc>(),
            accountBloc: context.read<AccountBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) {
            final authBloc = AuthBloc(
              authService: authService,
              usersService: usersService,
            );
            apiClient.onSessionExpired = () {
              authBloc.add(LogoutEvent());
            };
            return authBloc;
          },
        ),
        BlocProvider(
          create: (context) => OtpBloc(otpRepository: otpRepository),
        ),
        BlocProvider(
          create: (context) => AdminBloc(dataSource: dataSource),
        ),
        BlocProvider(
          create: (context) => LoanBloc(dataSource: dataSource),
        ),
        BlocProvider(
          create: (context) => CardBloc(
            getCardsUseCase: GetCardsUseCase(cardRepository),
            addCardUseCase: AddCardUseCase(cardRepository),
            freezeCardUseCase: FreezeCardUseCase(cardRepository),
            deleteCardUseCase: DeleteCardUseCase(cardRepository),
            updateCardControlsUseCase:
                UpdateCardControlsUseCase(cardRepository),
            changeCardPinUseCase: ChangeCardPinUseCase(cardRepository),
          ),
        ),
        BlocProvider(
          create: (context) => LanguageBloc()..add(LoadLanguageEvent()),
        ),
        BlocProvider(
          create: (context) => ThemeBloc()..add(LoadThemeEvent()),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(dataSource: dataSource),
        ),
        BlocProvider(
          create: (context) => SupportBloc(
            sendMessageUseCase: SendMessageUseCase(supportRepository),
          ),
        ),
        BlocProvider(
          create: (context) => ScheduledTransferBloc(
            getTransfersUseCase:
                GetScheduledTransfersUseCase(scheduledTransferRepository),
            createTransferUseCase:
                CreateScheduledTransferUseCase(scheduledTransferRepository),
            cancelTransferUseCase:
                CancelScheduledTransferUseCase(scheduledTransferRepository),
          ),
        ),
        BlocProvider(
          create: (context) => BudgetBloc(
            getBudgetsUseCase: GetBudgetsUseCase(budgetRepository),
            createBudgetUseCase: CreateBudgetUseCase(budgetRepository),
            getBudgetProgressUseCase:
                GetBudgetProgressUseCase(budgetRepository),
            updateBudgetUseCase: UpdateBudgetUseCase(budgetRepository),
            deleteBudgetUseCase: DeleteBudgetUseCase(budgetRepository),
          ),
        ),
        BlocProvider(
          create: (context) => SavingGoalBloc(
            getGoalsUseCase: GetSavingGoalsUseCase(savingGoalsRepository),
            createGoalUseCase: CreateSavingGoalUseCase(savingGoalsRepository),
            addFundsUseCase: AddSavingGoalFundsUseCase(savingGoalsRepository),
            withdrawFundsUseCase:
                WithdrawSavingGoalFundsUseCase(savingGoalsRepository),
            updateGoalUseCase: UpdateSavingGoalUseCase(savingGoalsRepository),
            deleteGoalUseCase: DeleteSavingGoalUseCase(savingGoalsRepository),
          ),
        ),
        BlocProvider(
          create: (context) => SearchBloc(
            searchUseCase: GlobalSearchUseCase(searchRepository),
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp(
                title: 'BankE',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.getLightTheme(themeState.accentColor.color),
                darkTheme: AppTheme.getDarkTheme(themeState.accentColor.color),
                themeMode: themeState.themeMode,
                locale: languageState.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                ],
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
