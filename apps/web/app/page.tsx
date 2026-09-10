'use client';

import React, { useState } from 'react';

export default function WebHomePage() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [activeReactionPostId, setActiveReactionPostId] = useState<string | null>(null);
  const [userReactions, setUserReactions] = useState<Record<string, string>>({ post_1: 'love' });
  const [savedPosts, setSavedPosts] = useState<Record<string, boolean>>({ post_1: true });
  const [commentInput, setCommentInput] = useState<Record<string, string>>({});
  const [commentsMap, setCommentsMap] = useState<Record<string, Array<{ id: string; name: string; avatar: string; text: string; time: string }>>>({
    post_1: [
      {
        id: 'c1',
        name: 'Sophia Martinez',
        avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
        text: 'The 3D glassmorphic web layout looks incredible Alex! Great work! 🔥👏',
        time: '1h ago',
      },
    ],
  });

  const toggleTheme = () => {
    const nextTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(nextTheme);
    document.documentElement.setAttribute('data-theme', nextTheme);
  };

  const handleSelectReaction = (postId: string, reactionKey: string) => {
    setUserReactions((prev) => ({
      ...prev,
      [postId]: prev[postId] === reactionKey ? '' : reactionKey,
    }));
    setActiveReactionPostId(null);
  };

  const handleAddComment = (postId: string) => {
    const text = commentInput[postId]?.trim();
    if (!text) return;

    const newComment = {
      id: `c_${Date.now()}`,
      name: 'Alex Johnson',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      text,
      time: 'Just now',
    };

    setCommentsMap((prev) => ({
      ...prev,
      [postId]: [...(prev[postId] || []), newComment],
    }));

    setCommentInput((prev) => ({ ...prev, [postId]: '' }));
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-main)' }}>
      {/* 1. DESKTOP FACEBOOK-STYLE HEADER */}
      <header className="connecta-header">
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{
            width: '36px',
            height: '36px',
            borderRadius: '50%',
            background: 'var(--gradient-brand)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#fff',
            fontWeight: '900',
            fontSize: '18px'
          }}>
            C
          </div>
          <span style={{ fontWeight: '900', letterSpacing: '1px', fontSize: '18px', color: 'var(--color-primary)' }}>
            CONNECTA
          </span>
          <div style={{
            display: 'flex',
            alignItems: 'center',
            background: 'var(--bg-input)',
            borderRadius: '20px',
            padding: '6px 14px',
            marginLeft: '12px',
            gap: '8px'
          }}>
            <span style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>🔍</span>
            <input
              type="text"
              placeholder="Search Connecta..."
              style={{
                border: 'none',
                background: 'transparent',
                outline: 'none',
                color: 'var(--text-primary)',
                fontSize: '14px',
                width: '180px'
              }}
            />
          </div>
        </div>

        {/* Center Nav Items */}
        <div style={{ display: 'flex', gap: '8px', height: '100%' }}>
          <button style={{
            padding: '0 24px',
            borderBottom: '3px solid var(--color-primary)',
            color: 'var(--color-primary)',
            fontSize: '20px'
          }}>
            🏠
          </button>
          <button style={{ padding: '0 24px', color: 'var(--text-secondary)', fontSize: '20px' }}>👥</button>
          <button style={{ padding: '0 24px', color: 'var(--text-secondary)', fontSize: '20px' }}>📺</button>
          <button style={{ padding: '0 24px', color: 'var(--text-secondary)', fontSize: '20px' }}>🏪</button>
          <button style={{ padding: '0 24px', color: 'var(--text-secondary)', fontSize: '20px' }}>👨‍👩‍👧‍👦</button>
        </div>

        {/* Right Action Icons */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <button onClick={toggleTheme} style={{
            width: '36px',
            height: '36px',
            borderRadius: '50%',
            background: 'var(--bg-input)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '16px'
          }}>
            {theme === 'light' ? '🌙' : '☀️'}
          </button>
          <button style={{
            width: '36px',
            height: '36px',
            borderRadius: '50%',
            background: 'var(--bg-input)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '16px'
          }}>
            💬
          </button>
          <button style={{
            width: '36px',
            height: '36px',
            borderRadius: '50%',
            background: 'var(--bg-input)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '16px'
          }}>
            🔔
          </button>
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80"
            alt="User Avatar"
            style={{ width: '36px', height: '36px', borderRadius: '50%', objectFit: 'cover', cursor: 'pointer' }}
          />
        </div>
      </header>

      {/* 2. THREE-COLUMN DESKTOP LAYOUT */}
      <div className="connecta-main-layout">
        {/* LEFT SIDEBAR NAVIGATION */}
        <aside className="connecta-left-sidebar">
          <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '10px', borderRadius: '8px', cursor: 'pointer' }}>
              <img
                src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80"
                alt="Alex"
                style={{ width: '36px', height: '36px', borderRadius: '50%', objectFit: 'cover' }}
              />
              <span style={{ fontWeight: '600' }}>Alex Johnson</span>
            </div>
            <SidebarItem icon="👥" label="Friends" />
            <SidebarItem icon="👨‍👩‍👧‍👦" label="Groups" />
            <SidebarItem icon="🚩" label="Pages" />
            <SidebarItem icon="🏪" label="Marketplace" />
            <SidebarItem icon="📺" label="Watch Video" />
            <SidebarItem icon="📅" label="Events" />
            <SidebarItem icon="⌛" label="Memories" />
            <SidebarItem icon="🔖" label="Saved Items" />
            <SidebarItem icon="⚙️" label="Settings & Privacy" />
          </div>
        </aside>

        {/* CENTER FEED */}
        <main style={{ maxWidth: '680px', width: '100%', margin: '0 auto' }}>
          {/* Stories Rail */}
          <div style={{ display: 'flex', gap: '10px', overflowX: 'auto', paddingBottom: '12px' }}>
            {/* Create Story */}
            <div style={{
              minWidth: '110px',
              height: '180px',
              borderRadius: '12px',
              background: 'var(--bg-card)',
              border: '1px solid var(--border-color)',
              position: 'relative',
              overflow: 'hidden',
              cursor: 'pointer'
            }}>
              <img
                src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80"
                alt="Create Story"
                style={{ width: '100%', height: '115px', objectFit: 'cover' }}
              />
              <div style={{
                position: 'absolute',
                bottom: '12px',
                left: '50%',
                transform: 'translateX(-50%)',
                textAlign: 'center'
              }}>
                <div style={{
                  width: '28px',
                  height: '28px',
                  borderRadius: '50%',
                  background: 'var(--color-primary)',
                  color: '#fff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '18px',
                  margin: '0 auto 4px auto'
                }}>+</div>
                <span style={{ fontSize: '11px', fontWeight: 'bold' }}>Create Story</span>
              </div>
            </div>

            {/* Friend Story */}
            <div style={{
              minWidth: '110px',
              height: '180px',
              borderRadius: '12px',
              backgroundImage: 'url("https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80")',
              backgroundSize: 'cover',
              position: 'relative',
              cursor: 'pointer'
            }}>
              <img
                src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80"
                alt="Sophia"
                style={{
                  width: '32px',
                  height: '32px',
                  borderRadius: '50%',
                  border: '3px solid var(--color-primary)',
                  position: 'absolute',
                  top: '8px',
                  left: '8px'
                }}
              />
              <span style={{
                position: 'absolute',
                bottom: '8px',
                left: '8px',
                color: '#fff',
                fontWeight: 'bold',
                fontSize: '11px',
                textShadow: '0 1px 3px rgba(0,0,0,0.8)'
              }}>
                Sophia M.
              </span>
            </div>
          </div>

          {/* Create Post Card */}
          <div className="connecta-card">
            <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
              <img
                src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80"
                alt="Avatar"
                style={{ width: '40px', height: '40px', borderRadius: '50%' }}
              />
              <input
                type="text"
                placeholder="What's on your mind, Alex?"
                style={{
                  flex: 1,
                  background: 'var(--bg-input)',
                  border: 'none',
                  borderRadius: '20px',
                  padding: '10px 16px',
                  outline: 'none',
                  color: 'var(--text-primary)',
                  cursor: 'pointer'
                }}
              />
            </div>
            <hr style={{ border: 'none', borderTop: '1px solid var(--border-color)', margin: '12px 0' }} />
            <div style={{ display: 'flex', justifyContent: 'space-around' }}>
              <button style={{ fontWeight: '600', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', gap: '6px' }}>
                📷 <span>Photo/Video</span>
              </button>
              <button style={{ fontWeight: '600', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', gap: '6px' }}>
                🏷️ <span>Tag Friends</span>
              </button>
              <button style={{ fontWeight: '600', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', gap: '6px' }}>
                😊 <span>Feeling/Activity</span>
              </button>
            </div>
          </div>

          {/* Feed Post Card */}
          <div className="connecta-card" style={{ position: 'relative' }}>
            {/* Post Header */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80"
                  alt="Alex Johnson"
                  style={{ width: '40px', height: '40px', borderRadius: '50%' }}
                />
                <div>
                  <div style={{ fontWeight: 'bold', display: 'flex', alignItems: 'center', gap: '4px' }}>
                    Alex Johnson <span style={{ color: 'var(--color-primary)' }}>☑️</span>
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>2 hours ago · 🌎 Public</div>
                </div>
              </div>
              <button style={{ fontSize: '18px', color: 'var(--text-secondary)' }}>⋯</button>
            </div>

            {/* Content Text */}
            <p style={{ marginBottom: '12px', fontSize: '15px' }}>
              Excited to announce the official launch of the CONNECTA Web & Mobile Platform! Built with modern glassmorphic responsive design, real-time messaging, 24h stories & marketplace! 🚀✨ #Connecta #BuildInPublic
            </p>

            {/* Post Media */}
            <img
              src="https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1200&auto=format&fit=crop&q=80"
              alt="Post Media"
              style={{ width: '100%', borderRadius: '12px', maxHeight: '380px', objectFit: 'cover', marginBottom: '12px' }}
            />

            {/* Reaction Summary */}
            <div style={{ display: 'flex', justifyContent: 'space-between', color: 'var(--text-secondary)', fontSize: '13px', marginBottom: '8px' }}>
              <div>👍 ❤️ 🥰 78 reactions</div>
              <div>{(commentsMap['post_1'] || []).length} comments · 15 shares</div>
            </div>
            <hr style={{ border: 'none', borderTop: '1px solid var(--border-color)', marginBottom: '8px' }} />

            {/* Action Buttons */}
            <div style={{ display: 'flex', justifyContent: 'space-between', position: 'relative' }}>
              {activeReactionPostId === 'post_1' && (
                <div style={{
                  position: 'absolute',
                  bottom: '40px',
                  left: '0',
                  background: 'var(--bg-card)',
                  borderRadius: '30px',
                  padding: '6px 14px',
                  boxShadow: 'var(--shadow-md)',
                  display: 'flex',
                  gap: '12px',
                  fontSize: '22px',
                  zIndex: 10
                }}>
                  {['👍', '❤️', '🥰', '😂', '😮', '😢', '😡'].map((emoji, idx) => (
                    <span key={idx} style={{ cursor: 'pointer' }} onClick={() => handleSelectReaction('post_1', emoji)}>
                      {emoji}
                    </span>
                  ))}
                </div>
              )}

              <button
                onMouseEnter={() => setActiveReactionPostId('post_1')}
                style={{
                  flex: 1,
                  padding: '8px',
                  fontWeight: '600',
                  color: userReactions['post_1'] ? 'var(--color-primary)' : 'var(--text-secondary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '6px'
                }}
              >
                <span>{userReactions['post_1'] || '👍'}</span>
                <span>{userReactions['post_1'] ? 'Liked' : 'Like'}</span>
              </button>

              <button style={{ flex: 1, padding: '8px', fontWeight: '600', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}>
                💬 <span>Comment</span>
              </button>

              <button style={{ flex: 1, padding: '8px', fontWeight: '600', color: 'var(--text-secondary)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}>
                ↗️ <span>Share</span>
              </button>
            </div>

            {/* Comments Thread */}
            <div style={{ marginTop: '12px', paddingTop: '12px', borderTop: '1px solid var(--border-color)' }}>
              {(commentsMap['post_1'] || []).map((c) => (
                <div key={c.id} style={{ display: 'flex', gap: '10px', marginBottom: '8px' }}>
                  <img src={c.avatar} alt={c.name} style={{ width: '32px', height: '32px', borderRadius: '50%' }} />
                  <div style={{ background: 'var(--bg-input)', padding: '8px 12px', borderRadius: '12px', maxWidth: '85%' }}>
                    <div style={{ fontWeight: 'bold', fontSize: '13px' }}>{c.name}</div>
                    <div style={{ fontSize: '13px' }}>{c.text}</div>
                  </div>
                </div>
              ))}

              <div style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                <input
                  type="text"
                  placeholder="Write a comment..."
                  value={commentInput['post_1'] || ''}
                  onChange={(e) => setCommentInput({ ...commentInput, post_1: e.target.value })}
                  onKeyDown={(e) => e.key === 'Enter' && handleAddComment('post_1')}
                  style={{
                    flex: 1,
                    background: 'var(--bg-input)',
                    border: 'none',
                    borderRadius: '18px',
                    padding: '8px 14px',
                    outline: 'none',
                    color: 'var(--text-primary)'
                  }}
                />
                <button
                  onClick={() => handleAddComment('post_1')}
                  style={{ background: 'var(--color-primary)', color: '#fff', padding: '0 16px', borderRadius: '18px', fontWeight: 'bold' }}
                >
                  Post
                </button>
              </div>
            </div>
          </div>
        </main>

        {/* RIGHT SIDEBAR CONTACTS & REQUESTS */}
        <aside className="connecta-right-sidebar">
          <div className="connecta-card">
            <h4 style={{ marginBottom: '12px', color: 'var(--text-secondary)' }}>Friend Requests</h4>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '8px' }}>
              <img
                src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80"
                alt="David"
                style={{ width: '40px', height: '40px', borderRadius: '50%' }}
              />
              <div>
                <div style={{ fontWeight: 'bold', fontSize: '14px' }}>David Miller</div>
                <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>14 mutual friends</div>
              </div>
            </div>
            <div style={{ display: 'flex', gap: '8px' }}>
              <button style={{ flex: 1, background: 'var(--color-primary)', color: '#fff', padding: '6px', borderRadius: '6px', fontWeight: 'bold' }}>
                Confirm
              </button>
              <button style={{ flex: 1, background: 'var(--bg-input)', color: 'var(--text-primary)', padding: '6px', borderRadius: '6px' }}>
                Delete
              </button>
            </div>
          </div>

          <div className="connecta-card">
            <h4 style={{ marginBottom: '12px', color: 'var(--text-secondary)' }}>Contacts (Online)</h4>
            <ContactItem name="Sophia Martinez" avatar="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80" />
            <ContactItem name="Marcus Chen" avatar="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80" />
            <ContactItem name="Emily Davis" avatar="https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80" />
          </div>
        </aside>
      </div>
    </div>
  );
}

function SidebarItem({ icon, label }: { icon: string; label: string }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '10px', borderRadius: '8px', cursor: 'pointer' }}>
      <span style={{ fontSize: '20px' }}>{icon}</span>
      <span style={{ fontWeight: '600', fontSize: '14px' }}>{label}</span>
    </div>
  );
}

function ContactItem({ name, avatar }: { name: string; avatar: string }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '6px 0', cursor: 'pointer' }}>
      <div className="avatar-online">
        <img src={avatar} alt={name} style={{ width: '34px', height: '34px', borderRadius: '50%', objectFit: 'cover' }} />
      </div>
      <span style={{ fontWeight: '500', fontSize: '14px' }}>{name}</span>
    </div>
  );
}
