<script setup>
import { ref, onMounted } from 'vue'
import CommentForm from './components/CommentForm.vue'
import CommentList from './components/CommentList.vue'
import LoginForm from './components/LoginForm.vue'

const API = import.meta.env.VITE_API_URL

const isLoggedIn = ref(false)
const justLoggedOut = ref(false)
const comments = ref([])

async function checkTokenValidity() {
  const token = localStorage.getItem('access')
  if (!token) {
    isLoggedIn.value = false
    return
  }

  try {
    const res = await fetch(`${API}/comments/`, {
      headers: { Authorization: `Bearer ${token}` }
    })
    isLoggedIn.value = res.ok
  } catch (err) {
    isLoggedIn.value = false
  }
}

async function loadComments() {
  const token = localStorage.getItem('access')
  if (!token) return

  try {
    const res = await fetch(`${API}/comments/`, {
      headers: { Authorization: `Bearer ${token}` }
    })
    if (!res.ok) throw new Error('Failed to fetch comments')
    const data = await res.json()
    comments.value = data.results || data
  } catch (err) {
    console.error('❌ Error loading comments:', err)
  }
}

onMounted(async () => {
  await checkTokenValidity()
  if (isLoggedIn.value) {
    loadComments()
  }
})

function handleLoginSuccess() {
  isLoggedIn.value = true
  justLoggedOut.value = false
  loadComments()
}

function logout() {
  localStorage.removeItem('access')
  localStorage.removeItem('refresh')
  isLoggedIn.value = false
  justLoggedOut.value = true
  comments.value = [] // очистка списку
}

function handleCommentSubmitted() {
  loadComments()
}
</script>

<template>
  <div>
    <div v-if="isLoggedIn">
      <button @click="logout">Logout</button>
      <CommentForm @submitted="handleCommentSubmitted" />
      <hr />
      <CommentList :initial-comments="comments" :key="comments.length" />
    </div>

    <div v-else>
      <LoginForm @login-success="handleLoginSuccess" />
      <p v-if="justLoggedOut" class="info">
        🔓 You have been logged out. Please log in again.
      </p>
    </div>
  </div>
</template>

<style scoped>
.info {
  background-color: #eaf4ff;
  color: #333;
  padding: 10px;
  border-left: 5px solid #2196F3;
  margin-top: 10px;
}
.alert.success {
  margin: 15px 0;
  padding: 10px;
  background-color: #d4edda;
  color: #155724;
  border-radius: 6px;
}
</style>
