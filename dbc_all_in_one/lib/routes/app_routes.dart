import 'package:flutter/material.dart';

import '../presentation/app_workflow_overview/app_workflow_overview.dart';
import '../presentation/business_dashboard/business_dashboard.dart';
import '../presentation/data_migration_center/data_migration_center.dart';
import '../presentation/global_search_center/global_search_center.dart';
import '../presentation/gst_filing_center/gst_filing_center.dart';
import '../presentation/gst_reports/gst_reports.dart';
import '../presentation/hiring_marketplace/hiring_marketplace.dart';
import '../presentation/inventory_management/inventory_management.dart';
import '../presentation/invoice_management_center/invoice_management_center.dart';
import '../presentation/live_camera_view/live_camera_view.dart';
import '../presentation/marketplace_product_catalog/marketplace_product_catalog.dart';
import '../presentation/news_updates_hub/news_updates_hub.dart';
import '../presentation/order_management_hub/order_management_hub.dart';
import '../presentation/payment_processing_center/payment_processing_center.dart';
import '../presentation/payroll_processing/payroll_processing.dart';
import '../presentation/security_alerts_dashboard/security_alerts_dashboard.dart';
import '../presentation/security_events_history/security_events_history.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/staff_hiring/staff_hiring_screen.dart';
import '../presentation/staff_management/staff_management.dart';
import '../presentation/vendor_marketplace/vendor_marketplace.dart';

class AppRoutes {
  static const String initial = '/';
  static const String appWorkflowOverview = '/app-workflow-overview';
  static const String liveCameraView = '/live-camera-view';
  static const String staffManagement = '/staff-management';
  static const String businessDashboard = '/business-dashboard';
  static const String splash = '/splash-screen';
  static const String securityEventsHistory = '/security-events-history';
  static const String hiringMarketplace = '/hiring-marketplace';
  static const String newsUpdatesHub = '/news-updates-hub';
  static const String vendorMarketplace = '/vendor-marketplace';
  static const String inventoryManagement = '/inventory-management';
  static const String payrollProcessing = '/payroll-processing';
  static const String staffHiring = '/staff-hiring';
  static const String marketplaceProductCatalog =
      '/marketplace-product-catalog';
  static const String orderManagementHub = '/order-management-hub';
  static const String securityAlertsDashboard = '/security-alerts-dashboard';
  static const String paymentProcessingCenter = '/payment-processing-center';
  static const String gstFilingCenter = '/gst-filing-center';
  static const String gstReports = '/gst-reports';
  static const String notificationCenter = '/notification-center';
  static const String notificationSettings = '/notification-settings';
  static const String dataMigrationCenter = '/data-migration-center';
  static const String invoiceManagementCenter = '/invoice-management-center';
  static const String globalSearchCenter = '/global-search-center';

  static Map<String, WidgetBuilder> get routes {
    return {
      initial: (context) => const SplashScreen(),
      appWorkflowOverview: (context) => const AppWorkflowOverview(),
      liveCameraView: (context) => const LiveCameraView(),
      staffManagement: (context) => const StaffManagement(),
      businessDashboard: (context) => const BusinessDashboard(),
      splash: (context) => const SplashScreen(),
      securityEventsHistory: (context) => const SecurityEventsHistory(),
      hiringMarketplace: (context) => const HiringMarketplace(),
      newsUpdatesHub: (context) => const NewsUpdatesHub(),
      vendorMarketplace: (context) => const VendorMarketplace(),
      inventoryManagement: (context) => const InventoryManagement(),
      payrollProcessing: (context) => const PayrollProcessing(),
      staffHiring: (context) => const StaffHiringScreen(),
      marketplaceProductCatalog: (context) => const MarketplaceProductCatalog(),
      orderManagementHub: (context) => const OrderManagementHub(),
      securityAlertsDashboard: (context) => const SecurityAlertsDashboard(),
      paymentProcessingCenter: (context) => const PaymentProcessingCenter(),
      gstFilingCenter: (context) => const GSTFilingCenter(),
      gstReports: (context) => const GSTReportsScreen(),

      dataMigrationCenter: (context) => const DataMigrationCenter(),
      invoiceManagementCenter: (context) => const InvoiceManagementCenter(),
      globalSearchCenter: (context) => const GlobalSearchCenter(),
    };
  }
}
