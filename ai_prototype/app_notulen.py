import time
import os
import warnings
from dotenv import load_dotenv

# ==============================================================================
# TRIK: Membungkam pesan FutureWarning agar terminal tetap bersih
# ==============================================================================
warnings.filterwarnings("ignore", category=FutureWarning)

import google.generativeai as genai

# ==============================================================================
# 1. LOAD API KEY DARI FILE .ENV
# ==============================================================================
load_dotenv()
GOOGLE_API_KEY = os.getenv("GEMINI_API_KEY")

if not GOOGLE_API_KEY:
    raise ValueError("API Key tidak ditemukan! Pastikan file .env sudah dibuat dan berisi GEMINI_API_KEY=milik_anda")

genai.configure(api_key=GOOGLE_API_KEY)

# ==============================================================================
# FUNGSI UTAMA: PROSES AUDIO -> NOTULENSI
# ==============================================================================
def proses_audio_rapat(file_audio_path, mode="standar"):
    print(f"Mempersiapkan file audio: {file_audio_path}...")

    # 2. LOGIKA SMART ROUTING (MENGGUNAKAN GEMINI 3.1)
    if mode == "pro":
        # Meskipun pakai library lama, kita tetap bisa panggil model terbaru!
        model_name = "gemini-3.1-pro-preview"
        print("Mode: HIGH ACCURACY (Gemini 3.1 Pro) diaktifkan.")
    else:
        model_name = "gemini-3.1-flash-lite-preview"
        print("Mode: STANDARD (Gemini 3.1 Flash) diaktifkan.")

    try:
        if not os.path.exists(file_audio_path):
            return f"Error: File audio '{file_audio_path}' tidak ditemukan."

        # 3. MENGUNGGAH AUDIO
        print("Mengunggah file audio ke server API (harap tunggu)...")
        audio_file = genai.upload_file(path=file_audio_path)
        
        while audio_file.state.name == "PROCESSING":
            print(".", end="", flush=True)
            time.sleep(2)
            audio_file = genai.get_file(audio_file.name)
            
        if audio_file.state.name == "FAILED":
            raise Exception("Server Google gagal memproses format file audio Anda.")
            
        print("\nUpload selesai!")

        # 4. PROMPT ENGINEERING
        prompt = """
        Kamu adalah asisten notulensi rapat cerdas khusus untuk profesional di Indonesia.
        Dengarkan rekaman audio ini secara saksama. Rekaman ini mungkin berisi campuran bahasa Indonesia baku, bahasa gaul (lu/gua, dll), campuran bahasa Inggris (code-switching), dan logat/dialek daerah.

        Tugasmu:
        1. Buatkan RINGKASAN PERCAKAPAN (poin-poin utama apa saja yang dibicarakan, abaikan obrolan basa-basi).
        2. Buatkan RANGKUMAN EKSEKUTIF (1-2 paragraf) dengan bahasa Indonesia formal, rapi, dan profesional untuk diserahkan ke atasan.
        3. Buatkan DAFTAR TUGAS (To-Do List) dengan *checkbox* jika ada instruksi, tenggat waktu (deadline), atau tindak lanjut yang disebutkan oleh pembicara.

        Format output harus rapi dan terstruktur menggunakan format Markdown.
        """

        # 5. EKSEKUSI MODEL AI
        print(f"AI ({model_name}) sedang mendengarkan, merangkum, dan menganalisis...")
        model = genai.GenerativeModel(model_name)
        response = model.generate_content([prompt, audio_file])

        hasil_teks = response.text

    except Exception as e:
        hasil_teks = f"Terjadi kesalahan teknis saat memproses: {e}"

    finally:
        # 6. PEMBERSIHAN FILE
        if 'audio_file' in locals():
            try:
                genai.delete_file(audio_file.name)
                print("File audio telah dihapus dari server untuk menjaga privasi pengguna.")
            except Exception as cleanup_error:
                print(f"Peringatan: Gagal menghapus file dari server: {cleanup_error}")

    return hasil_teks

# ==============================================================================
# BLOK EKSEKUSI
# ==============================================================================
if __name__ == "__main__":
    file_percobaan = os.path.join("sample_audio", "testing_rapat.mp3")

    print("\n" + "="*50)
    print("MEMULAI UJI COBA AI VOICE PENDANT")
    print("="*50)
    
    hasil_notulensi = proses_audio_rapat(file_percobaan, mode="pro")

    print("\n" + "="*50)
    print("HASIL NOTULENSI OTOMATIS:")
    print("="*50)
    print(hasil_notulensi)
    print("="*50 + "\n")