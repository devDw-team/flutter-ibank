import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/employee_registration_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/tasks/presentation/screens/task_add_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/calendar/presentation/screens/event_add_screen.dart';
import '../../features/calendar/presentation/screens/event_detail_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/projects/presentation/screens/project_add_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/projects/presentation/screens/project_edit_screen.dart';
import '../../features/projects/presentation/screens/development_log_form_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/profile/presentation/screens/password_change_screen.dart';
import '../../features/employees/presentation/screens/employee_add_screen.dart';
import '../../features/employees/presentation/screens/employee_list_screen.dart';
import '../../features/employees/presentation/screens/employee_edit_screen.dart';
import '../../features/employees/presentation/providers/employee_permission_provider.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/providers/supabase_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isAdmin = ref.watch(isAdminProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.session != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/splash' ||
                         state.matchedLocation == '/forgot-password';
      
      final isAdminRoute = state.matchedLocation == '/employee-registration' ||
                          state.matchedLocation == '/employee-add' ||
                          state.matchedLocation == '/employee-list';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      
      if (isLoggedIn && state.matchedLocation == '/login') {
        return '/';
      }
      
      // Admin route protection
      if (isAdminRoute && !isAdmin) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/employee-registration',
        builder: (context, state) => const EmployeeRegistrationScreen(),
      ),
      GoRoute(
        path: '/employee-add',
        builder: (context, state) => const EmployeeAddScreen(),
      ),
      GoRoute(
        path: '/employee-list',
        builder: (context, state) => const EmployeeListScreen(),
      ),
      GoRoute(
        path: '/employees/edit/:id',
        builder: (context, state) {
          final employeeId = state.pathParameters['id'] ?? '';
          return EmployeeEditScreen(employeeId: employeeId);
        },
      ),
      GoRoute(
        path: '/tasks/add',
        builder: (context, state) => const TaskAddScreen(),
      ),
      GoRoute(
        path: '/tasks/detail/:id',
        builder: (context, state) {
          final taskId = state.pathParameters['id'] ?? '';
          return TaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/calendar/add',
        builder: (context, state) => const EventAddScreen(),
      ),
      GoRoute(
        path: '/calendar/detail/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id'] ?? '';
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/projects/add',
        builder: (context, state) => const ProjectAddScreen(),
      ),
      GoRoute(
        path: '/projects/detail/:id',
        builder: (context, state) {
          final projectId = state.pathParameters['id'] ?? '';
          return ProjectDetailScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/projects/edit/:id',
        builder: (context, state) {
          final projectId = state.pathParameters['id'] ?? '';
          return ProjectEditScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/projects/:projectId/development-log/add',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          return DevelopmentLogFormScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/projects/:projectId/development-log/edit/:logId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          final logId = state.pathParameters['logId'] ?? '';
          return DevelopmentLogFormScreen(projectId: projectId, logId: logId);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/profile/password-change',
        builder: (context, state) => const PasswordChangeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}); 