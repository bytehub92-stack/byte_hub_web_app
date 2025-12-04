import 'package:admin_panel/core/constants/api_constants.dart';
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/core/services/image_upload_service.dart';
import 'package:admin_panel/core/services/image_upload_service_impl.dart';
import 'package:admin_panel/core/services/theme_service.dart';
import 'package:admin_panel/core/services/web_image_compression_service.dart';
import 'package:admin_panel/features/merchandisers/chats/data/datasources/chat_remote_datasource.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_bloc.dart';
import 'package:admin_panel/features/merchandisers/delivery/data/datasources/delivery_remote_datasource.dart';
import 'package:admin_panel/features/merchandisers/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:admin_panel/features/merchandisers/delivery/domain/repositories/delivery_repository.dart';
import 'package:admin_panel/features/merchandisers/delivery/presentation/bloc/delivery_bloc.dart';

import 'package:admin_panel/features/admin/admin_merchandiser_management/data/datasources/admin_stats_remote_datasource.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/repositories/admin_stats_repository_impl.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/repositories/admin_stats_repository.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/get_admin_stats.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/create_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/delete_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/category/update_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/create_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/delete_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/product/update_product_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/create_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/delete_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/domain/usecases/sub_category/update_sub_category_usecase.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/product_bloc/product_bloc.dart';
import 'package:admin_panel/features/merchandisers/store_management/presentation/bloc/sub_category_bloc/sub_category_bloc.dart';
import 'package:admin_panel/features/shared/app_settings/data/datasource/app_settings_remote_datasource.dart';
import 'package:admin_panel/features/shared/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:admin_panel/features/shared/notifications/data/repositories/notification_repository_impl.dart';
import 'package:admin_panel/features/shared/notifications/data/services/notification_service.dart';
import 'package:admin_panel/features/shared/notifications/domain/repositories/notification_repository.dart';
import 'package:admin_panel/features/shared/notifications/presentation/bloc/notification_bloc.dart';
import 'package:admin_panel/features/shared/offers/data/datasource/offers_remote_datasource.dart';
import 'package:admin_panel/features/shared/offers/data/repositories/offers_repository_impl.dart';
import 'package:admin_panel/features/shared/offers/data/services/offer_notification_service.dart';

import 'package:admin_panel/features/shared/offers/domain/repositories/offers_repository.dart';
import 'package:admin_panel/features/shared/offers/domain/usecase/create_offer_usecase.dart';
import 'package:admin_panel/features/shared/offers/domain/usecase/delete_offer_usecase.dart';
import 'package:admin_panel/features/shared/offers/domain/usecase/get_offer_by_id_usecase.dart';
import 'package:admin_panel/features/shared/offers/domain/usecase/get_offers_usecase.dart';
import 'package:admin_panel/features/shared/offers/domain/usecase/toggle_offer_status_usecase.dart';
import 'package:admin_panel/features/shared/offers/domain/usecase/update_offer_usecase.dart';
import 'package:admin_panel/features/shared/offers/presentation/bloc/offers_bloc.dart';
import 'package:admin_panel/features/shared/offers/services/offer_indicator_service.dart';
import 'package:admin_panel/features/shared/orders/data/datasources/orders_remote_datasource.dart';
import 'package:admin_panel/features/shared/orders/data/repositories/orders_repository_impl.dart';
import 'package:admin_panel/features/shared/orders/data/services/order_service.dart';
import 'package:admin_panel/features/shared/orders/domain/repositories/orders_repository.dart';
import 'package:admin_panel/features/shared/orders/domain/usecases/orders_usecases.dart';

import 'package:admin_panel/features/shared/orders/presentation/bloc/orders_bloc.dart';
import 'package:admin_panel/features/shared/profile/data/repositories/profile_repository.dart';
import 'package:admin_panel/features/shared/profile/presentation/bloc/profile_bloc.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/category_remote_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/customer_remote_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/product_remote_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/sub_category_remote_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/unit_remote_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/category_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/customer_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/product_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/sub_category_repositoy_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/unit_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/category_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/customer_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/product_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/sub_category_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/unit_repository.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/customer/get_customers_by_merchandiser.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/customer/toggle_customer_status.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_categories_usecase.dart';

import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_products_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_sub_categories_usecase.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/usecases/get_units_usecase.dart';
import 'package:admin_panel/features/merchandisers/chats/domain/usecases/get_conversation.dart';
import 'package:admin_panel/features/merchandisers/chats/domain/usecases/get_unread_count.dart';
import 'package:admin_panel/features/merchandisers/chats/domain/usecases/send_message.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/bloc/customer/customer_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/network_info.dart';
import '../debug/debug_config.dart';

import 'package:admin_panel/features/shared/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admin_panel/features/shared/auth/domain/usecases/logout_usecase.dart';
import '../../features/shared/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/shared/auth/data/datasources/auth_local_datasource.dart';
import '../../features/shared/auth/data/repositories/auth_repository_impl.dart';
import '../../features/shared/auth/domain/repositories/auth_repository.dart';
import '../../features/shared/auth/domain/usecases/login_usecase.dart';
import '../../features/shared/auth/presentation/bloc/auth_bloc.dart';

import 'package:admin_panel/features/admin/admin_merchandiser_data/bloc/merchandiser_data_bloc.dart';

import 'package:admin_panel/features/admin/admin_merchandiser_management/data/datasources/admin_remote_datasource.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/repositories/merchandiser_repository_impl.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/repositories/merchandiser_repository.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/create_merchandiser.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/get_merchandisers.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/toggle_merchandiser_status.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/merchandiser_bloc/merchandiser_bloc.dart';

import 'package:admin_panel/features/shared/shared_feature/data/datasources/merchandiser_stats_datasource.dart';
import 'package:admin_panel/features/shared/shared_feature/data/repositories/merchandiser_stats_repository_impl.dart';
import 'package:admin_panel/features/shared/shared_feature/domain/repositories/merchandiser_stats_repository.dart';

import 'package:admin_panel/features/shared/app_settings/data/repositories/app_settings_repository_impl.dart';
import 'package:admin_panel/features/shared/app_settings/domain/repositories/app_settings_repository.dart';
import 'package:admin_panel/features/shared/app_settings/domain/usecases/create_app_setting.dart';
import 'package:admin_panel/features/shared/app_settings/domain/usecases/get_about_section_settings.dart';
import 'package:admin_panel/features/shared/app_settings/domain/usecases/get_app_setting.dart';
import 'package:admin_panel/features/shared/app_settings/domain/usecases/update_app_setting.dart';
import 'package:admin_panel/features/shared/app_settings/presentation/bloc/app_settings_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Initialize Supabase with web-specific configuration
  try {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
      debug: true,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  } catch (e) {
    if (kIsWeb && e.toString().contains('getInitialAppLink')) {
      // Ignore app_links error on web - reinitialize without deep linking
      await Supabase.initialize(
        url: ApiConstants.supabaseUrl,
        anonKey: ApiConstants.supabaseAnonKey,
        debug: true,
      );
    } else {
      rethrow;
    }
  }

  sl.registerLazySingleton(() => Supabase.instance.client);

  sl.registerLazySingleton<ThemeService>(() => ThemeService());

  // Initialize debug configuration
  DebugConfig.initializeDebug();

  // local storage
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Network
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl<Connectivity>()),
  );

  sl.registerLazySingleton<AuthService>(
    () => AuthService(sl<SupabaseClient>()),
  );

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authService: sl(),
    ),
  );

  // Merchandisers Management
  sl.registerLazySingleton<MerchandiserRemoteDataSource>(
    () => MerchandiserRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<MerchandiserRepository>(
    () => MerchandiserRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetMerchandisers(sl()));
  sl.registerLazySingleton(() => CreateMerchandiser(sl()));
  sl.registerLazySingleton(() => ToggleMerchandiserStatus(sl()));
  sl.registerFactory(
    () => MerchandiserBloc(
      getMerchandisers: sl(),
      createMerchandiser: sl(),
      toggleMerchandiserStatus: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCategoriesByMerchandiserIdUseCase(sl()));
  sl.registerLazySingleton(() => GetSubCategoriesByCategoryId(sl()));
  sl.registerLazySingleton(() => GetProductsBySubCategoryUsecase(sl()));

  // Merchandiser Data
  sl.registerFactory(
    () => MerchandiserDataBloc(
      getCategoriesByMerchandiserIdUseCase: sl(),
      getSubCategoriesByCategoryId: sl(),
      getProductsBySubCategoryUsecase: sl(),
    ),
  );

  // Core -- Image Compression/Uploading
  sl.registerLazySingleton<WebImageCompressionService>(
    () => WebImageCompressionService(),
  );
  sl.registerLazySingleton<ImageUploadService>(
    () =>
        ImageUploadServiceImpl(supabaseClient: sl(), compressionService: sl()),
  );

  // Shared -- Admin/Merchandiser
  sl.registerLazySingleton(
    () => MerchandiserStatsDataSource(supabaseClient: sl()),
  );
  sl.registerLazySingleton<MerchandiserStatsRepository>(
    () => MerchandiserStatsRepositoryImpl(dataSource: sl()),
  );

  // ============= Notification Feature =============
  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // BLoC
  sl.registerFactory(() => NotificationBloc(sl()));

  // ============= Offers Feature =============

  // ============= Offer Indicator Service =============
  // Add this after the Offers BLoC registration

  sl.registerLazySingleton<OfferIndicatorService>(
    () => OfferIndicatorService(sl<OffersRemoteDataSource>()),
  );

  // Data sources
  sl.registerLazySingleton<OffersRemoteDataSource>(
    () => OffersRemoteDataSourceImpl(supabaseClient: sl(), authService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<OffersRepository>(
    () => OffersRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetOffersUseCase(sl()));
  sl.registerLazySingleton(() => GetOfferByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateOfferUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOfferUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOfferUseCase(sl()));
  sl.registerLazySingleton(() => ToggleOfferStatusUseCase(sl()));

  // ============= Offer Notification Service =============
  sl.registerLazySingleton<OfferNotificationService>(
    () => OfferNotificationService(sl<SupabaseClient>()),
  );

  // BLoC
  sl.registerFactory(
    () => OffersBloc(
      getOffersUseCase: sl(),
      getOfferByIdUseCase: sl(),
      createOfferUseCase: sl(),
      updateOfferUseCase: sl(),
      deleteOfferUseCase: sl(),
      toggleOfferStatusUseCase: sl(),
      notificationService: sl(),
    ),
  );

  // Merchandiser Dashboard

  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<SubCategoryRemoteDataSource>(
    () => SubCategoryRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SubCategoryRepository>(
    () => SubCategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerFactory(
    () => CategoryBloc(
      getCategoriesUseCase: sl(),
      createCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => CreateSubCategoryUsecase(sl()));
  sl.registerLazySingleton(() => DeleteSubCategoryUsecase(sl()));

  sl.registerLazySingleton(() => UpdateSubCategoryUsecase(sl()));
  sl.registerFactory(
    () => SubCategoryBloc(
      createSubCategory: sl(),
      deleteSubCategory: sl(),
      getSubCategoriesByCategoryId: sl(),
      updateSubCategory: sl(),
    ),
  );

  sl.registerLazySingleton(() => CreateProductUsecase(sl()));
  sl.registerLazySingleton(() => DeleteProductUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductUsecase(sl()));
  sl.registerFactory(
    () => ProductBloc(
      createProduct: sl(),
      deleteProduct: sl(),
      getProducts: sl(),
      updateProduct: sl(),
    ),
  );

  sl.registerLazySingleton<AdminStatsRemoteDataSource>(
    () => AdminStatsRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<AdminStatsRepository>(
    () => AdminStatsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetAdminStats(sl()));
  sl.registerFactory(() => AdminStatsBloc(getAdminStats: sl()));

  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(remoteDataSource: sl()),
  );

  // Customer
  sl.registerLazySingleton(() => GetCustomersByMerchandiser(sl()));
  sl.registerLazySingleton(() => ToggleCustomerStatus(sl()));

  // Message
  sl.registerLazySingleton(() => GetConversation(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetUnreadMessageCount(sl()));

  sl.registerFactory(
    () => CustomerBloc(
      getCustomersByMerchandiser: sl(),
      toggleCustomerStatus: sl(),
    ),
  );

  sl.registerLazySingleton(() => NotificationService(supabaseClient: sl()));

  // Data sources
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(remoteDataSource: sl()),
  );

  // ============= Order Service =============
  sl.registerLazySingleton<OrderService>(() => OrderService(sl()));

  sl.registerLazySingleton(() => GetAllOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersByMerchandiserUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePaymentStatusUseCase(sl()));

  sl.registerFactory(
    () => OrdersBloc(
      GetCustomerOrdersUseCase: sl(),
      getAllOrders: sl(),
      getOrdersByMerchandiser: sl(),
      getOrdersByCustomer: sl(),
      getOrderById: sl(),
      updateOrderStatus: sl(),
      updatePaymentStatus: sl(),
      orderService: sl(),
    ),
  );

  // ===================== Delivery Feature =====================

  // Bloc
  sl.registerFactory(() => DeliveryBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<DeliveryRepository>(
    () => DeliveryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<DeliveryRemoteDataSource>(
    () => DeliveryRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Chat Feature
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(sl<SupabaseClient>()),
  );

  sl.registerFactory<ChatBloc>(() {
    // Get merchandiser profile ID from auth session
    final session = sl<SupabaseClient>().auth.currentSession;
    final merchandiserProfileId = session?.user.id ?? '';

    return ChatBloc(
      dataSource: sl<ChatRemoteDataSource>(),
      merchandiserProfileId: merchandiserProfileId,
    );
  });

  // Profile Feature
  sl.registerFactory(() => ProfileBloc(repository: sl(), authService: sl()));

  sl.registerLazySingleton(
    () => ProfileRepository(
      sl(), // SupabaseClient
      sl(), // WebImageCompressionService
    ),
  );

  // Units of Measurement
  // Data sources
  sl.registerLazySingleton<UnitRemoteDataSource>(
    () => UnitRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<UnitRepository>(
    () => UnitRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUnitsUsecase(sl()));

  // ============= App Settings Feature (Shared) =============
  // Data sources
  sl.registerLazySingleton<AppSettingsRemoteDataSource>(
    () => AppSettingsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AppSettingsRepository>(
    () => AppSettingsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAppSetting(sl()));
  sl.registerLazySingleton(() => GetAboutSectionSettings(sl()));
  sl.registerLazySingleton(() => UpdateAppSetting(sl()));
  sl.registerLazySingleton(() => CreateAppSetting(sl()));

  // BLoC
  sl.registerFactory(
    () => AppSettingsBloc(
      getAppSetting: sl(),
      getAboutSectionSettings: sl(),
      updateAppSetting: sl(),
      createAppSetting: sl(),
    ),
  );
}
