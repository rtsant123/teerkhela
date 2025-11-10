import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forum_post.dart';
import '../models/game.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/shimmer_widgets.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TeerGame> _games = [];
  List<ForumPost> _posts = [];
  bool _isLoading = true;
  String? _error;
  String _selectedGame = 'all';

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final games = await ApiService.getGames();
      setState(() {
        _games = games;
        _tabController = TabController(
          length: games.length + 1, // +1 for "All Posts"
          vsync: this,
        );
        _tabController.addListener(_onTabChanged);
      });
      _loadPosts();
    } catch (e) {
      setState(() {
        _error = 'Unable to connect to server. Please check your internet connection.';
        _isLoading = false;
      });
      print('Forum error: $e');
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        if (_tabController.index == 0) {
          _selectedGame = 'all';
        } else {
          _selectedGame = _games[_tabController.index - 1].name;
        }
      });
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await ApiService.getForumPosts(
        game: _selectedGame == 'all' ? null : _selectedGame,
      );
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to load posts. Please check your internet connection.';
        _isLoading = false;
      });
      print('Forum load error: $e');
    }
  }

  Future<void> _handleLike(ForumPost post, String userId) async {
    try {
      final isLiked = post.isLikedBy(userId);

      // Optimistic update
      setState(() {
        final index = _posts.indexOf(post);
        if (index != -1) {
          final updatedLikedBy = List<String>.from(post.likedBy);
          if (isLiked) {
            updatedLikedBy.remove(userId);
          } else {
            updatedLikedBy.add(userId);
          }

          _posts[index] = ForumPost(
            id: post.id,
            userId: post.userId,
            username: post.username,
            game: post.game,
            predictionType: post.predictionType,
            numbers: post.numbers,
            confidence: post.confidence,
            description: post.description,
            likes: isLiked ? post.likes - 1 : post.likes + 1,
            likedBy: updatedLikedBy,
            createdAt: post.createdAt,
            isPremiumUser: post.isPremiumUser,
          );
        }
      });

      // Make API call
      if (isLiked) {
        await ApiService.unlikePost(post.id, userId);
      } else {
        await ApiService.likePost(post.id, userId);
      }
    } catch (e) {
      // Revert on error
      _loadPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_games.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        bottom: _games.isEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: AppTheme.subtitle1.copyWith(
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTheme.subtitle1.copyWith(
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(text: 'All Posts'),
                  ..._games.map((game) => Tab(text: game.displayName)),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(size, userProvider),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/create-forum-post');
          if (result == true) {
            _loadPosts();
          }
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: Text(
          'New Post',
          style: AppTheme.buttonText.copyWith(fontSize: size.width * 0.035),
        ),
      ),
    );
  }

  Widget _buildBody(Size size, UserProvider userProvider) {
    if (_isLoading) {
      return _buildShimmerLoading(size);
    }

    if (_error != null) {
      return _buildError(size);
    }

    if (_posts.isEmpty) {
      return _buildEmptyState(size);
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(size.width * 0.04),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index], size, userProvider);
        },
      ),
    );
  }

  Widget _buildPostCard(ForumPost post, Size size, UserProvider userProvider) {
    final userId = userProvider.userId ?? '';
    final isLiked = post.isLikedBy(userId);

    return Container(
      margin: EdgeInsets.only(bottom: size.width * 0.035),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.035),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simplified Header
            Row(
              children: [
                // User Avatar (smaller)
                Container(
                  width: size.width * 0.08,
                  height: size.width * 0.08,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      post.username[0].toUpperCase(),
                      style: AppTheme.heading3.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.space8),
                // Username and game info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.username,
                            style: AppTheme.subtitle1.copyWith(
                              fontSize: size.width * 0.036,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (post.isPremiumUser) ...[
                            SizedBox(width: AppTheme.space4),
                            Icon(
                              Icons.verified,
                              size: size.width * 0.035,
                              color: AppTheme.accent,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${_getGameDisplayName(post.game)} • ${post.predictionType} • ${post.getTimeAgo()}',
                        style: AppTheme.bodySmall.copyWith(
                          fontSize: size.width * 0.028,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.space12),

            // Numbers - The Main Focus
            Wrap(
              spacing: size.width * 0.02,
              runSpacing: size.width * 0.02,
              children: post.numbers.map((number) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.width * 0.015,
                  ),
                  decoration: BoxDecoration(
                    gradient: post.predictionType == 'FR'
                        ? LinearGradient(
                            colors: [AppTheme.frColor, AppTheme.frColor.withOpacity(0.8)],
                          )
                        : LinearGradient(
                            colors: [AppTheme.srColor, AppTheme.srColor.withOpacity(0.8)],
                          ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (post.predictionType == 'FR' ? AppTheme.frColor : AppTheme.srColor).withOpacity(0.25),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    number.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.038,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }).toList(),
            ),

            // Description (if present)
            if (post.description.isNotEmpty) ...[
              SizedBox(height: AppTheme.space12),
              Text(
                post.description,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: size.width * 0.033,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: AppTheme.space12),

            // Bottom Row: Confidence + Like
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Confidence Badge (smaller)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.02,
                    vertical: size.width * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(post.confidence).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: size.width * 0.032,
                        color: _getConfidenceColor(post.confidence),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${post.confidence}%',
                        style: TextStyle(
                          fontSize: size.width * 0.028,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(post.confidence),
                        ),
                      ),
                    ],
                  ),
                ),
                // Like Button
                GestureDetector(
                  onTap: () => _handleLike(post, userId),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.025,
                      vertical: size.width * 0.012,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: size.width * 0.042,
                          color: isLiked ? AppTheme.error : AppTheme.textTertiary,
                        ),
                        SizedBox(width: AppTheme.space4),
                        Text(
                          '${post.likes}',
                          style: TextStyle(
                            fontSize: size.width * 0.032,
                            fontWeight: FontWeight.w600,
                            color: isLiked ? AppTheme.error : AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(Size size) {
    return ListView.builder(
      padding: EdgeInsets.all(size.width * 0.04),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ShimmerForumCard(size: size);
      },
    );
  }

  Widget _buildError(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: size.width * 0.15,
              color: AppTheme.error,
            ),
            SizedBox(height: AppTheme.space16),
            Text(
              'Failed to load posts',
              style: AppTheme.heading3.copyWith(
                fontSize: size.width * 0.045,
              ),
            ),
            SizedBox(height: AppTheme.space8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: size.width * 0.035,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.space24),
            ElevatedButton.icon(
              onPressed: _loadPosts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.space24,
                  vertical: AppTheme.space12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: size.width * 0.18,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.space20),
            Text(
              'No Predictions Yet',
              style: AppTheme.heading2.copyWith(
                fontSize: size.width * 0.048,
              ),
            ),
            SizedBox(height: AppTheme.space12),
            Text(
              'Share your numbers and help\nthe community!',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: size.width * 0.034,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppTheme.space20),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.buttonShadow(AppTheme.primary),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/create-forum-post');
                  if (result == true) {
                    _loadPosts();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.width * 0.032,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                icon: Icon(Icons.add, size: size.width * 0.05),
                label: Text(
                  'Share Numbers',
                  style: TextStyle(
                    fontSize: size.width * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 90) {
      return AppTheme.success;
    } else if (confidence >= 80) {
      return AppTheme.info;
    } else if (confidence >= 70) {
      return AppTheme.warning;
    } else {
      return AppTheme.textTertiary;
    }
  }

  String _getGameDisplayName(String game) {
    final gameObj = _games.firstWhere(
      (g) => g.name == game,
      orElse: () => TeerGame(
        id: 0,
        name: game,
        displayName: game,
        frTime: '',
        srTime: '',
        isActive: true,
        scrapeEnabled: false,
        displayOrder: 0,
      ),
    );
    return gameObj.displayName;
  }
}
