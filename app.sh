#!/bin/bash

# script to-do list dengan status

# ansi code warna untuk estetikan penulisan
merah="\e[38;5;196m✗ "    # Merah cerah
hijau="\e[38;5;46m✓ "     # Hijau cerah
kuning="\e[38;5;226m⚠"   # Kuning cerah
orange="\e[38;5;214m "    # Orange/jingga
reset="\e[0m"

# deklarasi variable array
declare -a todo_list
declare -a task_status

# function untuk menambah tugas
add_task() {
   # ambil inputan dari user dengan validasi kosong dan duplikat dalam loop
   while true; do
     read -p "Nama tugas: " task
     if [[ -z "$task" ]]; then
       echo -e "${merah}Tugas tidak boleh kosong! silahkan coba lagi.${reset}"
       continue
     else
       # cek duplikasi nama tugas
       local duplikat=0 # variabel ini hanya berlaku didalam fungsi add_task
       for existing in "${todo_list[@]}"; do
         if [[ "$existing" == "$task - "* ]]; then # untuk cek duplikat
           echo -e "${kuning} Nama tugas sudah ada. Coba Lagi.${reset}"
           duplikat=1
           break
         fi
       done
       if [[ $duplikat -eq 1 ]]; then
         continue # ulangi ketika ada duplikasi
       else
         # jika tidak ada semua tambahkan kedalam array
         todo_list+=("$task - Pending")
         task_status+=("Pending")
         echo -e "${hijau}Tugas berhasil ditambahkan.${reset}"
         break
       fi
     fi
   done
}

# function untuk menampilkan tugas
display_todo() {
   if [ ${#todo_list[@]} -eq 0 ]; then
     echo -e "${merah}Belum ada tugas.${reset}"
     return
   fi

   echo -e "${orange}------ List tugas ------${reset}"
   for i in "${!todo_list[@]}"; do
      echo "$((i+1)). ${todo_list[$i]}"
   done
   echo -e "${orange}------------------------${reset}"
}

# function untuk menghapus tugas
delete_task() {
   if [[ ${#todo_list[@]} -eq 0 ]]; then
     echo -e "${merah}Tugas Kosong!${reset}"
     return
   fi

   # untuk menampilkan list tugas
   echo "Daftar list tugas"
   for i in "${!todo_list[@]}"; do
      echo "$((i+1)). ${todo_list[$i]}"
   done

   # mengambil inputan dari user tugas mana yang mau dihapus
   read -p "Masukan nomor tugas yang ingin dihapus: " idx
   if [[ $idx =~ ^[0-9]+$ ]] && (( idx >= 1 && idx <= ${#todo_list[@]} )); then
     unset todo_list[$((idx-1))]
     unset task_status[$((idx-1))]

     # Re-index kembali arraynya
     todo_list=("${todo_list[@]}")
     task_status=("${task_status[@]}")
     echo -e "${hijau}Tugas berhasil dihapus.${reset}"
   else
     echo -e "${merah}Input tidak valid!${reset}"
   fi
}

# function untuk menandai tugas selesai
mark_task() {
   local idx="$1" # parameter nomor tugas (validasinya sudah ada diluar fungsi)
   if [[ ${#todo_list[@]} -eq 0 ]]; then
     echo -e "${merah}Tugas Kosong!${reset}"
     return
   fi

   # update status di task_status dan todo_list
   task_status[$((idx-1))]="Done"

   # ambil namanya dari todo_list sebelumnya, lalu update
   local task=$(echo "${todo_list[$((idx-1))]%% - *}")
   todo_list[$((idx-1))]="$task - Done"
   echo -e "${hijau}Tugas ditandai selesai.${reset}"
}

# function untuk statistik to-do
stat_todo() {
   local tugas_selesai=0
   local tugas_pending=0
   # looping untuk menghitung berapa banyak tugas yang selesai & pending
   for status in "${task_status[@]}"; do
      # jika tugas sudah ditandai selesai tambah tugas_selesai jika belum tambah tugas_pending
      if [[ "$status" == "Done" ]]; then
        tugas_selesai=$((tugas_selesai + 1))
      elif [[ "$status" = "Pending" ]]; then
        tugas_pending=$((tugas_pending + 1))
      fi
   done
   echo "Statistik tugas."
   echo -e "${hijau}Tugas selesai: $tugas_selesai.${reset}"
   echo -e "${kuning} Tugas belum selesai: $tugas_pending.${reset}"
   echo "Total tugas: ${#todo_list[@]}"
}

# main menu utama dari apliaksi
while true; do
     echo -e "${orange}========= To-do List - Menu =========${reset}"
     echo "1. Lihat daftar tugas"
     echo "2. Tambah tugas"
     echo "3. Tandai tugas selesai"
     echo "4. Hapus tugas"
     echo "5. Lihat statistik"
     echo "6. Keluar"
     read -p "Opsi pilihan [1-6]: " choice

     case $choice in
       1)
         display_todo
         ;;
       2)
         add_task
         ;;
       3)
         if [[ ${#todo_list[@]} -eq 0 ]]; then
           echo -e "${merah}Tugas Kosong!${reset}"
         else
           # untuk menampilkan list tugas
           echo "Daftar list tugas"
           for i in "${!todo_list[@]}"; do
              echo "$((i+1)). ${todo_list[$i]}"
           done

           # menerima inputan user untuk menandai tugas yang selesai
           read -p "Masukan nomor tugas yang selesai: " idx
           if [[ $idx =~ ^[0-9]+$ ]] && (( idx >= 0 && idx <= ${#todo_list[@]} )); then
             mark_task "$idx"
           else
             echo -e "${merah}Input tidak valid!${reset}"
           fi
         fi
         ;;
       4)
         delete_task
         ;;
       5)
         stat_todo
         ;;
       6)
         echo "Keluar dari aplikasi"
         exit 0
         ;;
       *)
         echo "Pilihan tidak ada. Silahkan pilih lagi"
         ;;
     esac
done
