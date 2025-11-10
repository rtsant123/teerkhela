import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forum_post.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';

/// SIMPLE FORUM - Like Social Media Comments
/// - Just type and post (no complicated forms!)
/// - See all messages like a chat
/// - Like messages
class SimpleCommunityForum extends StatefulWidget {
  const SimpleCommunityForum({super.key});

  @override
  State<SimpleCommunityForum> createState() => _SimpleCommunityForumState();
}

class _SimpleCommunityForumState extends State<SimpleCommunityForum> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ForumPost> _posts = [];
  bool _isLoading = true;
  bool _isPosting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();

    // Auto-refresh every 10 seconds for real-time feel
    Future.delayed(const Duration(seconds: 10), _autoRefresh);
  }

  void _autoRefresh() {
    if (mounted) {
      _loadPosts(silent: true);
      Future.delayed(const Duration(seconds: 10), _autoRefresh);
    }
  }

  Future<void> _loadPosts({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final posts = await ApiService.getForumPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _error = 'Could not load messages';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _postMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type a message first!'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    // Check for URLs
    if (_containsUrl(message)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Links not allowed. Just share your thoughts!'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId ?? 'guest';
      final username = userProvider.user?.email?.split('@')[0] ?? 'User';

      await ApiService.createForumPost(
        userId: userId,
        username: username,
        game: 'shillong', // Default game
        predictionType: 'FR',
        numbers: [], // No numbers required for simple posts
        confidence: 0,
        description: message,
      );

      _messageController.clear();
      _loadPosts();

      // Scroll to top to see new message
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posted!'),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not post. Check your internet.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  bool _containsUrl(String text) {
    final urlPattern = RegExp(
      r'(https?:\/\/|www\.|\.com|\.net|\.org|\.in|\.co)',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text);
  }

  Future<void> _handleLike(ForumPost post) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId ?? '';

    try {
      if (post.isLikedBy(userId)) {
        await ApiService.unlikePost(post.id, userId);
      } else {
        await ApiService.likePost(post.id, userId);
      }
      _loadPosts(silent: true);
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Community Chat'),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPosts(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _buildMessagesList(size, userProvider),
          ),

          // Input Box at Bottom (like WhatsApp)
          _buildInputBox(size),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildMessagesList(Size size, UserProvider userProvider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            SizedBox(height: AppTheme.space16),
            Text(_error!, style: AppTheme.bodyMedium),
            SizedBox(height: AppTheme.space16),
            ElevatedButton(
              onPressed: () => _loadPosts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.space20),
            Text(
              'No messages yet',
              style: AppTheme.heading2,
            ),
            SizedBox(height: AppTheme.space8),
            Text(
              'Be the first to share!',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(AppTheme.space12),
        reverse: false, // New messages at top
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildMessageCard(_posts[index], size, userProvider);
        },
      ),
    );
  }

  Widget _buildMessageCard(ForumPost post, Size size, UserProvider userProvider) {
    final userId = userProvider.userId ?? '';
    final isLiked = post.isLikedBy(userId);
    final isMyMessage = post.userId == userId;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.space12),
      padding: EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: isMyMessage
            ? AppTheme.primary.withOpacity(0.08)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: isMyMessage
            ? Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: User + Time
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary,
                child: Text(
                  post.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppTheme.space8),
              // Username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.username,
                          style: AppTheme.subtitle1.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (post.isPremiumUser) ...[
                          SizedBox(width: AppTheme.space4),
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: AppTheme.accent,
                          ),
                        ],
                        if (isMyMessage) ...[
                          SizedBox(width: AppTheme.space4),
                          Text(
                            '(You)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      post.getTimeAgo(),
                      style: AppTheme.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.space12),

          // Message Text
          Text(
            post.description,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 15,
              height: 1.4,
            ),
          ),

          // Show numbers if any (optional)
          if (post.numbers.isNotEmpty) ...[
            SizedBox(height: AppTheme.space8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.numbers.map((num) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    num.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          SizedBox(height: AppTheme.space8),

          // Like Button
          Row(
            children: [
              InkWell(
                onTap: () => _handleLike(post),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isLiked ? AppTheme.error : AppTheme.textTertiary,
                      ),
                      if (post.likes > 0) ...[
                        SizedBox(width: 4),
                        Text(
                          '${post.likes}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isLiked ? AppTheme.error : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox(Size size) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppTheme.space12),
      child: SafeArea(
        child: Row(
          children: [
            // Text Input
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.space12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.textTertiary.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Share your thoughts...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: AppTheme.bodyMedium,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_isPosting,
                ),
              ),
            ),

            SizedBox(width: AppTheme.space8),

            // Send Button
            Material(
              color: _isPosting ? AppTheme.textTertiary : AppTheme.primary,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _isPosting ? null : _postMessage,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  child: _isPosting
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
