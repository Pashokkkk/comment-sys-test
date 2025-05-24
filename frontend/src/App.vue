<script setup>
import { ref, onMounted } from 'vue'
import CommentForm from './components/CommentForm.vue'
import CommentList from './components/CommentList.vue'
import LoginForm from './components/LoginForm.vue'

const API = import.meta.env.VITE_API_URL

const isLoggedIn = ref(false)
const justLoggedOut = ref(false)
const comments = ref([]) // ⬅ список для top-level коментарів

async function checkTokenValidity() {
  const token = localStorage.getItem('access')
  if (!token) {
    isLoggedIn.value = false
    return
  }

  try {
    const res = await fetch(`${API}/comments/`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
    isLoggedIn.value = res.ok
  } catch (err) {
    isLoggedIn.value = false
  }
}

onMounted(() => {
  checkTokenValidity()
})

function handleLoginSuccess() {
  isLoggedIn.value = true
  justLoggedOut.value = false
}

function logout() {
  localStorage.removeItem('access')
  localStorage.removeItem('refresh')
  isLoggedIn.value = false
  justLoggedOut.value = true
}

function addComment(newComment) {
  if (!newComment.parent_comment) {
    comments.value.unshift(newComment)
  }
}
</script>

<template>
  <div>
    <div v-if="isLoggedIn">
      <button @click="logout">Logout</button>
      <CommentForm @submitted="addComment" />
      <hr />
      <CommentList :initial-comments="comments" />
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
</style>
