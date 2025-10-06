import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/status_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/models/status_model.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildMyStatusSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildRecentUpdates(), _buildViewedUpdates()],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Status',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showStatusMenu,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Recent updates'),
          Tab(text: 'Viewed updates'),
        ],
      ),
    );
  }

  Widget _buildMyStatusSection() {
    final myStatusAsync = ref.watch(myStatusStreamProvider);
    final currentUser = ref.watch(authServiceProvider).currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: myStatusAsync.when(
        data: (myStatuses) => _buildMyStatusTile(myStatuses, currentUser),
        loading: () => _buildMyStatusSkeleton(),
        error: (error, stack) => _buildMyStatusError(),
      ),
    );
  }

  Widget _buildMyStatusTile(List<StatusModel> myStatuses, currentUser) {
    final hasStatus = myStatuses.isNotEmpty;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: hasStatus
                    ? AppColors.primaryGreen
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: currentUser?.photoURL != null
                  ? CachedNetworkImage(
                      imageUrl: currentUser!.photoURL!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 30),
                      ),
                    )
                  : Container(
                      color: AppColors.primaryGreen,
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.add, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
      title: Text(
        hasStatus ? 'My status' : 'My status',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        hasStatus ? 'Tap to view updates' : 'Tap to add status update',
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
      ),
      onTap: () {
        if (hasStatus) {
          _viewMyStatus(myStatuses);
        } else {
          _showAddStatusOptions();
        }
      },
    );
  }

  Widget _buildMyStatusSkeleton() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
      ),
      title: Container(height: 16, width: 100, color: Colors.grey.shade300),
      subtitle: Container(height: 14, width: 150, color: Colors.grey.shade300),
    );
  }

  Widget _buildMyStatusError() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.error),
      ),
      title: const Text('Error loading status'),
      subtitle: const Text('Tap to retry'),
      onTap: () => ref.refresh(myStatusStreamProvider),
    );
  }

  Widget _buildRecentUpdates() {
    final statusAsync = ref.watch(statusStreamProvider);

    return statusAsync.when(
      data: (statuses) {
        // Group statuses by user
        final groupedStatuses = <String, List<StatusModel>>{};
        for (final status in statuses) {
          if (!groupedStatuses.containsKey(status.userId)) {
            groupedStatuses[status.userId] = [];
          }
          groupedStatuses[status.userId]!.add(status);
        }

        if (groupedStatuses.isEmpty) {
          return _buildEmptyState();
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groupedStatuses.length,
            itemBuilder: (context, index) {
              final userId = groupedStatuses.keys.elementAt(index);
              final userStatuses = groupedStatuses[userId]!;
              final latestStatus = userStatuses.first;

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildStatusTile(latestStatus, userStatuses),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => _buildLoadingList(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildViewedUpdates() {
    // Similar to recent updates but for viewed statuses
    return const Center(child: Text('Viewed updates coming soon!'));
  }

  Widget _buildStatusTile(StatusModel status, List<StatusModel> userStatuses) {
    final hasMultiple = userStatuses.length > 1;
    final hasUnviewed = userStatuses.any(
      (s) =>
          !s.viewedBy.contains(ref.read(authServiceProvider).currentUser?.uid),
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: hasUnviewed
                    ? AppColors.primaryGreen
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: status.userProfileUrl != null
                  ? CachedNetworkImage(
                      imageUrl: status.userProfileUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 30),
                      ),
                    )
                  : Container(
                      color: AppColors.primaryGreen,
                      child: Text(
                        status.userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),
          ),
          if (hasMultiple)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  '${userStatuses.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        status.userName,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        status.timeRemainingText,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
      ),
      onTap: () => _viewStatus(userStatuses),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No status updates',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status updates from your contacts will appear here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        title: Container(height: 16, width: 120, color: Colors.grey.shade300),
        subtitle: Container(height: 14, width: 80, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(statusStreamProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "edit_status",
          mini: true,
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.grey.shade700,
          onPressed: _showTextStatusCreator,
          child: const Icon(Icons.edit),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "camera_status",
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          onPressed: () => _pickMediaStatus(ImageSource.camera),
          child: const Icon(Icons.camera_alt),
        ),
      ],
    );
  }

  void _showStatusMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Status privacy'),
            onTap: () {
              Navigator.pop(context);
              _showStatusPrivacy();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            onTap: () {
              Navigator.pop(context);
              _showStatusHelp();
            },
          ),
        ],
      ),
    );
  }

  void _showAddStatusOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatusOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        color: Colors.red,
                        onTap: () => _pickMediaStatus(ImageSource.camera),
                      ),
                      const SizedBox(width: 24),
                      _buildStatusOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        color: Colors.purple,
                        onTap: () => _pickMediaStatus(ImageSource.gallery),
                      ),
                      const SizedBox(width: 24),
                      _buildStatusOption(
                        icon: Icons.text_fields,
                        label: 'Text',
                        color: AppColors.primaryGreen,
                        onTap: _showTextStatusCreator,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _viewMyStatus(List<StatusModel> statuses) {
    // Navigate to status viewer with my statuses
    _showSnackBar('My status viewer coming soon!');
  }

  void _viewStatus(List<StatusModel> statuses) {
    // Navigate to status viewer
    _showSnackBar('Status viewer coming soon!');
  }

  Future<void> _pickMediaStatus(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: source);
      if (file != null) {
        // Navigate to status editor
        _showSnackBar('Status editor coming soon!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _showTextStatusCreator() {
    // Navigate to text status creator
    _showSnackBar('Text status creator coming soon!');
  }

  void _showStatusPrivacy() {
    _showSnackBar('Status privacy settings coming soon!');
  }

  void _showStatusHelp() {
    _showSnackBar('Status help coming soon!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primaryGreen),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
