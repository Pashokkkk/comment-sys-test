<template>
  <div>
    <h2>🗨 All Comments</h2>

    <!-- Sort options -->
    <select v-model="ordering" @change="fetchComments">
      <option value="-created_at">Newest</option>
      <option value="created_at">Oldest</option>
      <option value="username">Username A→Z</option>
      <option value="-username">Username Z→A</option>
      <option value="email">Email A→Z</option>
      <option value="-email">Email Z→A</option>
    </select>

    <!-- Loading indicator -->
    <div v-if="loading" class="loader">Loading comments...</div>

    <!-- Render comment items -->
    <div v-else>
      <comment-item
        v-for="comment in comments"
        :key="comment.id"
        :comment="comment"
      />
    </div>

    <!-- Pagination controls -->
    <div class="pagination" style="margin-top: 20px;">
      <button :disabled="page === 1" @click="page--">Previous</button>
      <span>Page {{ page }}</span>
      <button :disabled="!hasMore" @click="page++">Next</button>
    </div>
  </div>
</template>

<script>
import CommentItem from './CommentItem.vue'
const API = import.meta.env.VITE_API_URL

export default {
  components: { CommentItem },
  data() {
    return {
      comments: [],
      page: 1,
      hasMore: true,
      loading: false,
      ordering: '-created_at',
    }
  },
  watch: {
    page: 'fetchComments',
    ordering: 'fetchComments',
  },
  mounted() {
    this.fetchComments()

    // WebSocket для live-коментарів
    const socket = new WebSocket(
      (window.location.protocol === 'https:' ? 'wss://' : 'ws://') +
      window.location.host +
      '/ws/comments/'
    )

    socket.onmessage = (event) => {
      const newComment = JSON.parse(event.data)

      // Додати тільки top-level коментар
      if (!newComment.parent_comment) {
        this.comments.unshift(newComment)
      }
    }
  },
  methods: {
    async fetchComments() {
      this.loading = true
      try {
        const res = await fetch(`${API}/comments/?page=${this.page}&ordering=${this.ordering}`)
        const data = await res.json()
        this.comments = data.results
        this.hasMore = !!data.next
      } catch (err) {
        console.error('❌ Failed to load comments', err)
      } finally {
        this.loading = false
      }
    },
    // Цей метод викликається з CommentForm @submitted
    addComment(newComment) {
      if (!newComment.parent_comment) {
        this.comments.unshift(newComment)
      }
    }
  }
}
</script>

<style>
.loader {
  text-align: center;
  margin: 20px;
  font-weight: bold;
  color: #555;
}
.comment-content strong {
  font-weight: bold;
}
</style>
