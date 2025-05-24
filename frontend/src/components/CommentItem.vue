<template>
  <div class="comment">
    <div class="comment-header">
      <div class="comment-avatar"></div>
      <div class="comment-meta">
        <strong>{{ localComment.username }}</strong>
        <div class="comment-email">{{ localComment.email }}</div>
        <div class="comment-date">{{ new Date(localComment.created_at).toLocaleString() }}</div>
      </div>
    </div>

    <!-- Show homepage if available -->
    <p v-if="localComment.homepage_url">
      🌐 <a :href="localComment.homepage_url" target="_blank" rel="noopener noreferrer">
        {{ localComment.homepage_url }}
      </a>
    </p>

    <!-- Display comment content -->
    <div class="comment-content" v-html="localComment.text"></div>

    <!-- Show image preview with lightbox -->
    <div v-if="isImage(localComment.file_upload)" class="comment-media">
      <a
        :href="resolveUrl(localComment.file_upload)"
        data-lightbox="image-set"
        :data-title="localComment.username"
      >
        <img
          :src="resolveUrl(localComment.file_upload)"
          class="comment-image-preview"
        />
      </a>
    </div>

    <!-- Show download link for text file -->
    <div v-else-if="isTextFile(localComment.file_upload)">
      <a :href="resolveUrl(localComment.file_upload)" target="_blank">📎 Download attached file</a>
    </div>

    <!-- Display replies recursively -->
    <div class="replies" v-if="localComment.replies && localComment.replies.length">
      <CommentItem
        v-for="reply in localComment.replies"
        :key="reply.id"
        :comment="reply"
      />
    </div>
  </div>

  <!-- Toggle reply form -->
  <button @click="toggleReply" style="margin-bottom: 20px;">↩️ Reply</button>

  <div v-if="showReplyForm" class="reply-form" style="margin-bottom: 0px;">
    <CommentForm :parentId="localComment.id" @submitted="onReplySubmitted" />
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import CommentItem from './CommentItem.vue'
import CommentForm from './CommentForm.vue'

const props = defineProps({
  comment: Object
})


const localComment = reactive({ ...props.comment })
  
const backendBase = (import.meta.env.VITE_API_URL || 'http://localhost:8000').replace('/api', '')
const showReplyForm = ref(false)

// Toggle reply form visibility
function toggleReply() {
  showReplyForm.value = !showReplyForm.value
}

async function fetchReplies() {
  try {
    const res = await fetch(`${import.meta.env.VITE_API_URL}/comments/?parent_comment=${props.comment.id}`)
    const data = await res.json()
    props.comment.replies = data.results
  } catch (error) {
    console.error("❌ Failed to fetch replies:", error)
  }
}

function onReplySubmitted(newReply) {
  showReplyForm.value = false

  // Ініціалізуємо replies, якщо вони ще не створені
  if (!localComment.replies) {
    localComment.replies = []
  }

  localComment.replies.push(newReply)
}


// Resolve full file URL
function resolveUrl(path) {
  return path || ''
}

// Check if file is an image
function isImage(url) {
  return /\.(jpg|jpeg|png|gif)$/i.test(url || '')
}

// Check if file is a text file
function isTextFile(url) {
  return /\.(txt|md)$/i.test(url || '')
}
</script>


<style scoped>
.comment {
  background-color: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 10px;
  padding: 15px;
  margin-bottom: 5px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);
  max-width: 700px;
}

.comment-header {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.comment-avatar {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background-color: #ddd;
  margin-right: 12px;
}

.comment-meta {
  font-size: 14px;
  color: #333;
}

.comment-meta strong {
  display: block;
  font-weight: 600;
  margin-bottom: 2px;
}

.comment-email {
  font-size: 13px;
  color: #777;
}

.comment-date {
  font-size: 12px;
  color: #aaa;
  margin-top: 2px;
}

.comment-content {
  font-size: 15px;
  line-height: 1.5;
  margin-top: 10px;
  margin-bottom: 10px;
}

.comment-image-preview {
  max-width: 100%;
  max-height: 300px;
  border-radius: 8px;
  margin-top: 8px;
  transition: transform 0.3s ease;
  cursor: pointer;
  border: 2px solid transparent;
}

.comment-image-preview:hover {
  transform: scale(1.02);
  border-color: orange;
  box-shadow: 0 0 8px rgba(255, 165, 0, 0.5);
}

.replies {
  margin-top: 20px;
  margin-left: 40px;
  border-left: 2px solid #eee;
  padding-left: 15px;
}

.comment-url {
  font-size: 13px;
  color: #1a0dab;
  margin-top: 4px;
  display: block;
}
</style>
