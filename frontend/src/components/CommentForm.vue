<template>
  <form @submit.prevent="handleSubmit" class="comment-form">
    <h2>💬 Leave a Comment</h2>

    <div class="form-group">
      <label>Username:</label>
      <input v-model="form.username" type="text" required />
    </div>

    <div class="form-group">
      <label>Email:</label>
      <input v-model="form.email" type="email" required />
    </div>

    <div class="form-group">
      <label>Homepage URL:</label>
      <input v-model="form.homepage_url" type="url" />
    </div>

    <div class="form-group">
      <label>Comment Text:</label>
      <div class="tag-buttons">
        <button type="button" @click="insertTag('i')">[i]</button>
        <button type="button" @click="insertTag('strong')">[strong]</button>
        <button type="button" @click="insertTag('code')">[code]</button>
        <button type="button" @click="insertLink">[a]</button>
      </div>
      <textarea v-model="form.text" required rows="4"></textarea>
    </div>

    <div class="form-group captcha-group">
      <label>Enter CAPTCHA:</label>
      <img :src="captchaImageUrl" alt="captcha" class="captcha-img" />
      <button type="button" @click="refreshCaptcha" class="refresh-btn">🔄</button>
      <input v-model="form.captcha_text" type="text" required />
    </div>

    <div class="form-group">
      <label>Upload File (optional):</label>
      <input type="file" @change="handleFile" ref="fileInput" />
    </div>

    <div class="form-actions">
      <button type="button" @click="previewVisible = !previewVisible">
        {{ previewVisible ? 'Hide Preview' : 'Show Preview' }}
      </button>
      <button type="submit" class="submit-btn">Submit</button>
    </div>

    <div v-if="previewVisible" class="preview">
      <h4>📄 Preview:</h4>
      <p><strong>{{ form.username }}</strong> ({{ form.email }})</p>
      <p v-html="form.text"></p>
    </div>

    <div v-if="successMessage" class="alert success">{{ successMessage }}</div>
    <div v-if="errorMessage" class="alert error">{{ errorMessage }}</div>
  </form>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'

const fileInput = ref(null)

const API = import.meta.env.VITE_API_URL
const emit = defineEmits(['submitted'])

const form = reactive({
  username: '',
  email: '',
  homepage_url: '',
  text: '',
  captcha_text: '',
  captcha_key: '',
  file: null
})

const props = defineProps({
  parentId: Number
})

const captchaImageUrl = ref('')
const previewVisible = ref(false)
const successMessage = ref('')
const errorMessage = ref('')

onMounted(() => {
  refreshCaptcha()
})

function resetForm() {
  console.log('🧹 Resetting form now...')
  form.username = ''
  form.email = ''
  form.homepage_url = ''
  form.text = ''
  form.captcha_text = ''
  form.captcha_key = ''
  form.file = null
  if (fileInput.value) {
    fileInput.value.value = '' 
  }
  refreshCaptcha()
}

async function refreshCaptcha() {
  try {
    const res = await fetch(`${API}/captcha/refresh/`)
    const data = await res.json()
    form.captcha_key = data.key
    captchaImageUrl.value = API.replace(/\/api\/?$/, '') + data.image_url
    form.captcha_text = ''
  } catch (error) {
    console.error('❌ Failed to refresh CAPTCHA', error)
  }
}

function handleFile(event) {
  form.file = event.target.files[0]
}

function insertTag(tag) {
  form.text += `<${tag}></${tag}>`
}

function insertLink() {
  form.text += `<a href="https://">link</a>`
}

async function handleSubmit() {
  console.log('🚀 handleSubmit called')
  errorMessage.value = ''
  successMessage.value = ''

  if (!form.username || !form.email || !form.text || !form.captcha_text) {
    errorMessage.value = '⚠️ Please fill in all required fields!'
    return
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(form.email)) {
    errorMessage.value = '⚠️ Please enter a valid email address!'
    return
  }

  const token = localStorage.getItem('access')
  if (!token) {
    errorMessage.value = '🔒 You are not logged in. Please log in.'
    return
  }

  const formData = new FormData()
  formData.append('username', form.username)
  formData.append('email', form.email)
  formData.append('homepage_url', form.homepage_url || '')
  formData.append('text', form.text)
  formData.append('captcha_key', form.captcha_key)
  formData.append('captcha_text', form.captcha_text)

  if (props.parentId) {
    formData.append('parent_comment', props.parentId)
  }
  if (form.file) {
    formData.append('file_upload', form.file)
  }

  try {
    console.log("🌍 API =", API)
    console.log("📤 Sending form data:")
    for (let pair of formData.entries()) {
      console.log(`${pair[0]}:`, pair[1])
    }

    const response = await fetch(`${API}/comments/`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: formData
    })

    const contentType = response.headers.get('content-type') || ''
    const responseBody = contentType.includes('application/json')
      ? await response.json()
      : {}

    if (!response.ok) {
      const errorText =
        responseBody?.captcha_text?.[0] ||
        responseBody?.text?.[0] ||
        responseBody?.detail ||
        '❌ Failed to submit'
    
      if (
        response.status === 401 &&
        responseBody?.code === 'token_not_valid' &&
        responseBody?.messages?.some(msg => msg.message?.includes('Token is expired'))
      ) {
        throw new Error('🔑 Your session has expired. Please log in again.')
      }
    
      throw new Error(errorText)
    }

    successMessage.value = '✅ Comment submitted!'
    console.log('✅ Comment successfully emitted and shown!')

    emit('submitted', responseBody)

    // Очистка форми через 3 сек
    setTimeout(() => {
      console.log('🧹 Now resetting the form and hiding success message...')
      resetForm()
    }, 3000)

    setTimeout(() => {
      successMessage.value = ''
    }, 5000)
  } catch (error) {
    errorMessage.value = error.message
    console.error('❌ Submit error:', error)
  }
}


</script>

<style scoped>
.alert.success {
  background-color: #d4edda;
  color: #155724;
  padding: 10px;
  border-radius: 6px;
  margin-top: 10px;
}
.alert.error {
  background-color: #f8d7da;
  color: #721c24;
  padding: 10px;
  border-radius: 6px;
  margin-top: 10px;
}

.comment-form {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  background: #fdfdfd;
  border: 1px solid #ddd;
  border-radius: 8px;
  box-shadow: 0 0 6px rgba(0, 0, 0, 0.05);
}

h2 {
  margin-bottom: 15px;
  color: #333;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  font-weight: bold;
  margin-bottom: 5px;
}

input[type="text"],
input[type="email"],
input[type="url"],
input[type="file"],
textarea {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid #ccc;
  border-radius: 6px;
}

textarea {
  resize: vertical;
}

.tag-buttons button {
  margin-right: 5px;
  padding: 5px 8px;
  border: none;
  background: #eee;
  border-radius: 4px;
  cursor: pointer;
}

.tag-buttons button:hover {
  background: #ddd;
}

.captcha-group {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.captcha-img {
  height: 40px;
  border: 1px solid #ccc;
}

.refresh-btn {
  background: #f0f0f0;
  border: none;
  padding: 6px;
  border-radius: 4px;
  cursor: pointer;
}

.refresh-btn:hover {
  background: #e0e0e0;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 15px;
}

.submit-btn {
  background-color: #4CAF50;
  color: white;
  padding: 8px 15px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.submit-btn:hover {
  background-color: #45a049;
}

.preview {
  background: #f8f8f8;
  padding: 10px;
  margin-top: 10px;
  border-left: 3px solid #2196F3;
}

.alert {
  margin-top: 10px;
  padding: 10px;
  border-radius: 6px;
}

.success {
  background-color: #d4edda;
  color: #155724;
}

.error {
  background-color: #f8d7da;
  color: #721c24;
}
</style>
