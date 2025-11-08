const express = require('express');
const router = express.Router();
const forumController = require('../controllers/forumController');

// Create new post
router.post('/posts', forumController.createPost);

// Get posts by game
router.get('/posts/game/:game', forumController.getPostsByGame);

// Get latest posts (all games)
router.get('/posts/latest', forumController.getLatestPosts);

// Get user's posts
router.get('/posts/user/:userId', forumController.getUserPosts);

// Like/Unlike post
router.post('/posts/like', forumController.likePost);
router.post('/posts/unlike', forumController.unlikePost);

// Delete post
router.delete('/posts/:postId', forumController.deletePost);

// Get community trends
router.get('/trends/:game/:predictionType', forumController.getCommunityTrends);

// Get hot predictions
router.get('/hot-predictions', forumController.getHotPredictions);

module.exports = router;
