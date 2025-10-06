// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/models/chat_model.dart';
import '../../../shared/widgets/custom_text_field.dart';

import '../../contacts/screens/contacts_screen.dart';
import '../../status/screens/status_screen.dart';
import '../../calls/screens/call_screen.dart';

class ChatHomeScreen extends ConsumerStatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  ConsumerState<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends ConsumerState<ChatHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(),
          const StatusScreen(),
          const CallScreen(),
          const ContactsScreen(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: _isSearching
          ? CustomTextField(
              controller: _searchController,
              hintText: 'Search chats...',
              prefixIcon: Icons.search,
              suffixIconData: Icons.clear,
              onSuffixTap: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              autofocus: true,
            )
          : Row(
              children: [
                Text(
                  'Talkative',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
      actions: _isSearching
          ? null
          : [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Search',
              ),
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'new_group',
                    child: ListTile(
                      leading: Icon(Icons.group_add_rounded),
                      title: Text('New Group'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'new_broadcast',
                    child: ListTile(
                      leading: Icon(Icons.campaign_rounded),
                      title: Text('New Broadcast'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'archived_chats',
                    child: ListTile(
                      leading: Icon(Icons.archive_rounded),
                      title: Text('Archived Chats'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings_rounded),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryGreen,
        indicatorWeight: 3,
        labelColor: AppColors.primaryGreen,
        unselectedLabelColor: Theme.of(
          context,
        ).textTheme.bodyMedium?.color?.withOpacity(0.6),
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.chat_rounded), text: 'Chats'),
          Tab(icon: Icon(Icons.radio_button_checked_rounded), text: 'Status'),
          Tab(icon: Icon(Icons.call_rounded), text: 'Calls'),
          Tab(icon: Icon(Icons.contacts_rounded), text: 'Contacts'),
        ],
      ),
    );
  }

  Widget _buildChatsTab() {
    final chatsAsync = ref.watch(chatsStreamProvider);

    return chatsAsync.when(
      data: (chats) {
        final filteredChats = _searchQuery.isEmpty
            ? chats
            : chats
                  .where(
                    (chat) =>
                        chat.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        (chat.lastMessage?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false),
                  )
                  .toList();

        if (filteredChats.isEmpty && _searchQuery.isNotEmpty) {
          return _buildEmptySearch();
        }

        if (filteredChats.isEmpty) {
          return _buildEmptyChats();
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: _buildChatTile(chat)),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error.toString()),
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: chat.isPinned
            ? AppColors.primaryGreen.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildChatAvatar(chat),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chat.isPinned)
              Icon(
                Icons.push_pin_rounded,
                size: 16,
                color: AppColors.primaryGreen,
              ),
            const SizedBox(width: 4),
            if (chat.lastMessageTime != null)
              Text(
                timeago.format(chat.lastMessageTime!),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            if (chat.isMuted)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.volume_off_rounded,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            Expanded(
              child: Text(
                chat.lastMessage ?? 'No messages yet',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chat.hasUnreadMessages(
              ref.read(authServiceProvider).currentUserId ?? '',
            ))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chat
                      .getUnreadCount(
                        ref.read(authServiceProvider).currentUserId ?? '',
                      )
                      .toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _openChat(chat),
        onLongPress: () => _showChatOptions(chat),
      ),
    );
  }

  Widget _buildChatAvatar(ChatModel chat) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
          backgroundImage: chat.imageUrl != null && chat.imageUrl!.isNotEmpty
              ? CachedNetworkImageProvider(chat.imageUrl!)
              : null,
          child: chat.imageUrl == null || chat.imageUrl!.isEmpty
              ? Text(
                  chat.name.isNotEmpty ? chat.name[0].toUpperCase() : 'C',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                )
              : null,
        ),
        if (chat.isGroupChat)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_rounded,
                size: 16,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyChats() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 100,
            color: AppColors.primaryGreen.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No chats yet',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your contacts\nor create a new group',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.contacts);
            },
            icon: const Icon(Icons.chat_rounded),
            label: Text(
              'Start Chatting',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(chatsStreamProvider);
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: FloatingActionButton(
            onPressed: _showNewChatOptions,
            backgroundColor: AppColors.primaryGreen,
            child: const Icon(Icons.add_comment_rounded, color: Colors.white),
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'new_group':
        Navigator.of(context).pushNamed(AppRouter.groupCreation);
        break;
      case 'new_broadcast':
        break;
      case 'archived_chats':
        break;
      case 'settings':
        Navigator.of(context).pushNamed(AppRouter.settings);
        break;
    }
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'New Chat',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_add_rounded),
              title: Text(
                'New Chat',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRouter.contacts);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add_rounded),
              title: Text(
                'New Group',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRouter.groupCreation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign_rounded),
              title: Text(
                'New Broadcast',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openChat(ChatModel chat) {
    Navigator.of(
      context,
    ).pushNamed(AppRouter.chat, arguments: {'chatId': chat.id});
  }

  void _showChatOptions(ChatModel chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                chat.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(chat.isPinned ? 'Unpin Chat' : 'Pin Chat'),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatServiceProvider).toggleChatPin(chat.id);
              },
            ),
            ListTile(
              leading: Icon(chat.isMuted ? Icons.volume_up : Icons.volume_off),
              title: Text(chat.isMuted ? 'Unmute Chat' : 'Mute Chat'),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatServiceProvider).toggleChatMute(chat.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Chat'),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatServiceProvider).toggleChatArchive(chat.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Chat',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteChat(chat);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteChat(ChatModel chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: const Text(
          'This chat will be deleted permanently. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(chatServiceProvider).deleteChat(chat.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
