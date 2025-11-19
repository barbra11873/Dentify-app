import React, { useState } from 'react';

const Dashboard = () => {
  // Mock data
  const [posts, setPosts] = useState([
    { id: 1, title: 'Recent Post 1', author: 'User1', views: 120, category: 'tech', tags: ['react', 'frontend'], status: 'published', likes: 10, comments: [] },
    { id: 2, title: 'Popular Post 1', author: 'User2', views: 500, category: 'lifestyle', tags: ['travel'], status: 'published', likes: 25, comments: [{ id: 1, text: 'Great post!', author: 'User3' }] },
    { id: 3, title: 'Recent Post 2', author: 'User3', views: 80, category: 'educative', tags: ['learning'], status: 'published', likes: 5, comments: [] },
  ]);

  const [filterCategory, setFilterCategory] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [sortOption, setSortOption] = useState('newest');

  const filteredPosts = posts.filter(post =>
    (filterCategory ? post.category === filterCategory : true) &&
    (searchTerm ? post.title.toLowerCase().includes(searchTerm.toLowerCase()) : true)
  );

  // Apply sorting to the filtered posts
  const sortedPosts = sortOption
    ? [...filteredPosts].sort((a, b) => {
        if (sortOption === 'newest') return b.id - a.id; // higher id == newer
        if (sortOption === 'mostLiked') return b.likes - a.likes;
        if (sortOption === 'mostCommented') return b.comments.length - a.comments.length;
        return 0;
      })
    : filteredPosts;

  const recentPosts = sortedPosts.slice(0, 2);
  const popularPosts = sortedPosts.filter(post => post.views > 100);
  const profileViews = 150;
  const postCount = posts.length;
  const likesReceived = posts.reduce((sum, p) => sum + (p.likes || 0), 0);
  const commentsMade = posts.reduce((sum, p) => sum + (p.comments ? p.comments.length : 0), 0);
  // Compute tag counts for trending tags
  const tagCounts = posts.reduce((acc, p) => {
    (p.tags || []).forEach(tag => {
      acc[tag] = (acc[tag] || 0) + 1;
    });
    return acc;
  }, {});

  const trendingTags = Object.entries(tagCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 6); // top 6 tags

  return (
    <div className="dashboard">
      <div className="profile-view-tab">
        <span>{profileViews}</span>
      </div>
      <h1>Dashboard</h1>

      <div className="user-stats">
        <div className="stat-card">
          <div className="stat-value">{postCount}</div>
          <div className="stat-label">Posts</div>
        </div>
        <div className="stat-card">
          <div className="stat-value">{likesReceived}</div>
          <div className="stat-label">Likes Received</div>
        </div>
        <div className="stat-card">
          <div className="stat-value">{commentsMade}</div>
          <div className="stat-label">Comments</div>
        </div>
      </div>

      <div className="filters">
        <input type="text" placeholder="Search posts..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} />
        <select value={filterCategory} onChange={(e) => setFilterCategory(e.target.value)}>
          <option value="">All Categories</option>
          <option value="tech">Tech</option>
          <option value="lifestyle">Lifestyle</option>
          <option value="educative">Educative</option>
        </select>
        <label style={{display: 'flex', alignItems: 'center', gap: '0.5rem'}}>
          Sort by:
          <select value={sortOption} onChange={(e) => setSortOption(e.target.value)}>
            <option value="newest">Newest</option>
            <option value="mostLiked">Most Liked</option>
            <option value="mostCommented">Most Commented</option>
          </select>
        </label>
      </div>
      <div className="dashboard-content">
        <section>
          <h2>Recent Posts</h2>
          {recentPosts.map(post => (
            <div key={post.id} className="post">
              <h3>{post.title}</h3>
              <p>By {post.author} - Category: {post.category} - Tags: {post.tags.join(', ')}</p>
              <p>Likes: {post.likes} | Comments: {post.comments.length}</p>
              <button onClick={() => console.log('Like post', post.id)}>Like</button>
              <button onClick={() => console.log('Dislike post', post.id)}>Dislike</button>
              <button onClick={() => console.log('Edit post', post.id)}>Edit</button>
              <button onClick={() => console.log('Delete post', post.id)}>Delete</button>
              <button onClick={() => console.log('Archive post', post.id)}>Archive</button>
              <div className="comments">
                {post.comments.map(comment => (
                  <div key={comment.id} className="comment">
                    <p>{comment.text} - By {comment.author}</p>
                    <button onClick={() => console.log('Reply to comment', comment.id)}>Reply</button>
                    <button onClick={() => console.log('Approve comment', comment.id)}>Approve</button>
                    <button onClick={() => console.log('Delete comment', comment.id)}>Delete</button>
                  </div>
                ))}
                <input type="text" placeholder="Add comment..." />
                <button>Add Comment</button>
              </div>
            </div>
          ))}
        </section>
        <section>
          <h2>Popular Posts from Friends & Following</h2>
          <div className="posts-horizontal">
            {popularPosts.map(post => (
              <div key={post.id} className="post">
                <h3>{post.title}</h3>
                <p>By {post.author} - {post.views} views</p>
                <p>Likes: {post.likes} | Comments: {post.comments.length}</p>
                <button onClick={() => console.log('Like post', post.id)}>Like</button>
                <button onClick={() => console.log('Dislike post', post.id)}>Dislike</button>
                <button onClick={() => console.log('Edit post', post.id)}>Edit</button>
                <button onClick={() => console.log('Delete post', post.id)}>Delete</button>
                <button onClick={() => console.log('Archive post', post.id)}>Archive</button>
                <div className="comments">
                  {post.comments.map(comment => (
                    <div key={comment.id} className="comment">
                      <p>{comment.text} - By {comment.author}</p>
                      <button onClick={() => console.log('Reply to comment', comment.id)}>Reply</button>
                      <button onClick={() => console.log('Approve comment', comment.id)}>Approve</button>
                      <button onClick={() => console.log('Delete comment', comment.id)}>Delete</button>
                    </div>
                  ))}
                  <input type="text" placeholder="Add comment..." />
                  <button>Add Comment</button>
                </div>
              </div>
            ))}
          </div>
        </section>
        
        <section>
          <h2>Discovery</h2>
          <div>
            <input type="text" placeholder="Search posts or users..." />
            <button>Search</button>
          </div>
          <div>
            <h3>Sort Posts</h3>
            <select>
              <option>Newest</option>
              <option>Most Liked</option>
              <option>Most Viewed</option>
            </select>
          </div>
          <div>
            <h3>Create Tags</h3>
            <input type="text" placeholder="Add new tag..." />
            <button>Add Tag</button>
          </div>
          <div className="trending-section">
            <h3>Trending Tags</h3>
            <div className="trending-tags">
              {trendingTags.length ? trendingTags.map(([tag, count]) => (
                <button key={tag} className="tag" onClick={() => { setSearchTerm(tag); }}>
                  {tag} <span className="tag-count">{count}</span>
                </button>
              )) : <p>No tags yet</p>}
            </div>
          </div>
          <div>
            <h3>Share Profile Link</h3>
            <p>https://blog-app.com/profile/JohnDoe</p>
            <button onClick={() => navigator.clipboard.writeText('https://blog-app.com/profile/JohnDoe')}>Copy Link</button>
          </div>
        </section>
      </div>
    </div>
  );
};

export default Dashboard;