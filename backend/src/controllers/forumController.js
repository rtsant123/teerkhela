const ForumPost = require('../models/ForumPost');

// Create new forum post
const createPost = async (req, res) => {
  try {
    const { userId, username, game, predictionType, numbers, confidence, description } = req.body;

    if (!userId || !game || !predictionType || !numbers || numbers.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: userId, game, predictionType, numbers'
      });
    }

    if (!['FR', 'SR'].includes(predictionType)) {
      return res.status(400).json({
        success: false,
        message: 'predictionType must be either FR or SR'
      });
    }

    if (numbers.length > 10) {
      return res.status(400).json({
        success: false,
        message: 'Maximum 10 numbers allowed'
      });
    }

    const post = await ForumPost.create(
      userId,
      username,
      game,
      predictionType,
      numbers,
      confidence,
      description
    );

    res.json({
      success: true,
      post
    });
  } catch (error) {
    console.error('Error creating forum post:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating forum post'
    });
  }
};

// Get posts by game
const getPostsByGame = async (req, res) => {
  try {
    const { game } = req.params;
    const limit = parseInt(req.query.limit) || 50;

    const posts = await ForumPost.getByGame(game, limit);

    res.json({
      success: true,
      posts,
      count: posts.length
    });
  } catch (error) {
    console.error('Error getting forum posts:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting forum posts'
    });
  }
};

// Get latest posts (all games)
const getLatestPosts = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    const posts = await ForumPost.getLatest(limit);

    res.json({
      success: true,
      posts,
      count: posts.length
    });
  } catch (error) {
    console.error('Error getting latest posts:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting latest posts'
    });
  }
};

// Get user's posts
const getUserPosts = async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 50;

    const posts = await ForumPost.getByUser(userId, limit);

    res.json({
      success: true,
      posts,
      count: posts.length
    });
  } catch (error) {
    console.error('Error getting user posts:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting user posts'
    });
  }
};

// Like a post
const likePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const { userId } = req.body;

    if (!postId || !userId) {
      return res.status(400).json({
        success: false,
        message: 'Missing postId or userId'
      });
    }

    const liked = await ForumPost.like(postId, userId);

    res.json({
      success: true,
      liked
    });
  } catch (error) {
    console.error('Error liking post:', error);
    res.status(500).json({
      success: false,
      message: 'Error liking post'
    });
  }
};

// Unlike a post
const unlikePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const { userId } = req.body;

    if (!postId || !userId) {
      return res.status(400).json({
        success: false,
        message: 'Missing postId or userId'
      });
    }

    const unliked = await ForumPost.unlike(postId, userId);

    res.json({
      success: true,
      unliked
    });
  } catch (error) {
    console.error('Error unliking post:', error);
    res.status(500).json({
      success: false,
      message: 'Error unliking post'
    });
  }
};

// Delete post
const deletePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'Missing userId'
      });
    }

    const deleted = await ForumPost.delete(postId, userId);

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: 'Post not found or unauthorized'
      });
    }

    res.json({
      success: true,
      message: 'Post deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting post:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting post'
    });
  }
};

// Get community trends
const getCommunityTrends = async (req, res) => {
  try {
    const { game, predictionType } = req.params;

    if (!['FR', 'SR'].includes(predictionType)) {
      return res.status(400).json({
        success: false,
        message: 'predictionType must be either FR or SR'
      });
    }

    const trends = await ForumPost.getTrends(game, predictionType);

    res.json({
      success: true,
      game,
      predictionType,
      trends
    });
  } catch (error) {
    console.error('Error getting community trends:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting community trends'
    });
  }
};

// Get hot predictions (most liked)
const getHotPredictions = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const posts = await ForumPost.getHotPredictions(limit);

    res.json({
      success: true,
      posts,
      count: posts.length
    });
  } catch (error) {
    console.error('Error getting hot predictions:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting hot predictions'
    });
  }
};

module.exports = {
  createPost,
  getPostsByGame,
  getLatestPosts,
  getUserPosts,
  likePost,
  unlikePost,
  deletePost,
  getCommunityTrends,
  getHotPredictions
};
