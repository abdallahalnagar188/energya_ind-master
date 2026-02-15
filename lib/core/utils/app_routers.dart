import 'package:energya_ind/frontend/home/view/engineering/engineering_view.dart';
import 'package:energya_ind/frontend/home/view/material/view/edit_material_list.dart';
import 'package:energya_ind/frontend/home/view/material/view/material_list_add_steps.dart';
import 'package:energya_ind/frontend/home/view/production/screen/assemplay_insert_page.dart';
import 'package:energya_ind/frontend/home/view/production/screen/dispatch_insert_page.dart';
import 'package:energya_ind/frontend/home/view/production/screen/followup_insert_page.dart';
import 'package:energya_ind/frontend/home/view/production/screen/glavonization_insert_page.dart';
import 'package:energya_ind/frontend/home/view/production/screen/painting_insert_page.dart';
import 'package:energya_ind/frontend/home/view/production/screen/prepraction_insert_page.dart';
import 'package:energya_ind/frontend/home/view/production/screen/visual_insert_page.dart';
import 'package:energya_ind/frontend/home/view/production/screen/welding_insrt_page.dart';
import 'package:energya_ind/frontend/home/view/production/widgets/production_grid_view_widget.dart';
import 'package:energya_ind/frontend/home/view/reports/reports_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:energya_ind/frontend/home/view/home_view.dart';
import 'package:energya_ind/frontend/initial/sign%20in/sign_in.dart';
import 'package:energya_ind/frontend/initial/splash/splash_view.dart';
import '../../frontend/initial/register/sign_up_view.dart';

abstract class AppRouters {
  static String kSplashViewpage = '/';

  static String kHomeView = '/homeView';

  static String kSignInPage = '/SignInView';

  static String kregisterPage = '/signUpView';

  static String kProductionGridViewPage = '/ProductionGridViewPage';

  static String kFollowUpPage = '/FollowUpPage';

  static String kPrepractionInsertPage = '/PrepractionInsertPage';

  static String kAssemplayInsertPage = '/AssemplayInsertPage';

  static String kWeldingInsertPage = '/WeldingInsertPage';

  static String kvisualInsertPage = '/visualInsertPage';

  static String kGlavonizationInsertPage = '/GlavonizationInsertPage';

  static String kDispatchInsertPage = '/DispatchInsertPage';

  static String kPaintingInsertPage = '/PaintingInsertPage';

  static String kEngineeringViewPage = '/EngineeringViewPage';

  static String kUploadMaterialViewPage = '/UploadMaterialViewPage';

  static String kEditMaterialPage = '/EditMaterialPage';

  static String kReportsPage = '/ReportsPage';

  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: kSignInPage,
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: kregisterPage,
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: kHomeView,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: kProductionGridViewPage,
        builder: (context, state) => const ProductionGridViewPage(),
      ),
      GoRoute(
        path: kFollowUpPage,
        builder: (context, state) => const FollowUpInsertPage(),
      ),
      GoRoute(
        path: kPrepractionInsertPage,
        builder: (context, state) => const PrepractionInsertPage(),
      ),
      GoRoute(
        path: kAssemplayInsertPage,
        builder: (context, state) => const AssemplayInsertPage(),
      ),
      GoRoute(
        path: kWeldingInsertPage,
        builder: (context, state) => const WeldingInsrtPage(),
      ),
      GoRoute(
        path: kvisualInsertPage,
        builder: (context, state) => const VisualInsertPage(),
      ),
      GoRoute(
        path: kGlavonizationInsertPage,
        builder: (context, state) => const GlavonizationInsertPage(),
      ),
      GoRoute(
        path: kDispatchInsertPage,
        builder: (context, state) => const DispatchInsertPage(),
      ),
      GoRoute(
        path: kPaintingInsertPage,
        builder: (context, state) => const PaintingInsertPage(),
      ),
      GoRoute(
        path: kEngineeringViewPage,
        builder: (context, state) => const EngineeringView(),
      ),
      GoRoute(
        path: kEngineeringViewPage,
        builder: (context, state) => const EngineeringView(),
      ),
      GoRoute(
        path: kEditMaterialPage,
        builder: (context, state) => const EditMaterialList(),
      ),
      GoRoute(
        path: kReportsPage,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: kUploadMaterialViewPage,
        builder: (context, state) {
          Map<String, dynamic> model = state.extra as Map<String, dynamic>;
          return MaterialListAddSteps(
            tags: model,
          );
        },
      ),
    ],
  );
}
