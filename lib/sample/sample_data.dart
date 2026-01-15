final Map<String, dynamic> appData = {
  "users": [
    {
      "id": "user_001",
      "name": "Yun Winner",
      "email": "winner@brossart.com",
      "password": "12345678",
      "createdAt": "2025-01-12",

      "profileImage":
          "https://scontent.fpnh5-4.fna.fbcdn.net/v/t39.30808-6/484447987_1182847360231289_296100024115737949_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGcZ5sCgmzALAkR1fL4kz0VO_nPc605L607-c9zrTkvrVykI1HR125_bE38xwWqOYBhJ6n4qSKWnhVhJTD-U_wj&_nc_ohc=Ys7Ex354LFoQ7kNvwHrMmLU&_nc_oc=AdmkwzNKa1ECA4ShCAylZLHUyu0rnMLkLpk6INdWd-0WQEFH612LFnCBdeHggHUqhas&_nc_zt=23&_nc_ht=scontent.fpnh5-4.fna&_nc_gid=6KfTXJ3IgV2E239WGms4KA&oh=00_Afn5OyYzycfi4AA8a58q6q7xsIrNR3p_roYy_Nus2eomVQ&oe=69387757",

      "tasks": [
        {
          "id": "task_001",
          "date": "Dec 5, 2025",
          "time": "8:00 AM",
          "text": "Go to Market",
          "checked": false,
          "reminder": true,
          "reminderTime": "07:50 AM",
        },
        {
          "id": "task_002",
          "date": "Dec 5, 2025",
          "time": "10:00 AM",
          "text": "Buy groceries",
          "checked": false,
          "reminder": true,
          "reminderTime": "09:45 AM",
        },
        {
          "id": "task_003",
          "date": "Dec 4, 2025",
          "time": "1:00 PM",
          "text": "Study Flutter",
          "checked": false,
          "reminder": false,
        },
        {
          "id": "task_004",
          "date": "Dec 8, 2025",
          "time": "4:00 PM",
          "text": "Team meeting",
          "checked": false,
          "reminder": true,
          "reminderTime": "03:45 PM",
        },
      ],

      "notifications": [
        {
          "id": "noti_001",
          "title": "Buy groceries",
          "date": "Dec 27, 2025",
          "message": "Pick up milk, eggs, fruits, and bread from the store.",
        },
        {
          "id": "noti_002",
          "title": "Finish project report",
          "date": "Dec 19, 2025",
          "message": "Complete the final draft and review it.",
        },
        {
          "id": "noti_003",
          "title": "Workout session",
          "date": "Dec 20, 2025",
          "message": "Attend a 30-minute workout session.",
        },
      ],

      "reminders": [
        {
          "id": "rem_001",
          "taskId": "task_001",
          "title": "Go to Market",
          "time": "07:50 AM",
          "date": "Dec 18, 2025",
        },
        {
          "id": "rem_002",
          "taskId": "task_004",
          "title": "Team meeting",
          "time": "03:45 PM",
          "date": "Dec 19, 2025",
        },
      ],
    },

    // -----------------------------
    // NEW USER 002 — TEPY
    // -----------------------------
    {
      "id": "user_002",
      "name": "Tepy Tes",
      "email": "tepy@sreysart.com",
      "password": "90946115",
      "createdAt": "2025-01-15",

      "profileImage":
          "https://instagram.fpnh5-2.fna.fbcdn.net/v/t51.2885-19/544139958_18085978318882423_3223882014065355359_n.jpg?efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby4xMDgwLmMyIn0&_nc_ht=instagram.fpnh5-2.fna.fbcdn.net&_nc_cat=107&_nc_oc=Q6cZ2QGfHAndbacyF2hOW9kO4Z276tC8qJZoF6RB53YB5oHeOVpsQyKbO62j4Vdqn3Lxr7E&_nc_ohc=bhWsQOVIxnIQ7kNvwEGYJdC&_nc_gid=GkkZxylAZzio0ZIXhSYafg&edm=AP4sbd4BAAAA&ccb=7-5&oh=00_AflqlnFfGV5AppzG7wZRsYS79OAuOZRR4McrPFYa19CO8g&oe=693A02E9&_nc_sid=7a9f4b",

      "tasks": [
        {
          "id": "task_101",
          "date": "Dec 6, 2025",
          "time": "7:00 AM",
          "text": "Morning yoga",
          "checked": false,
          "reminder": true,
          "reminderTime": "06:45 AM",
        },
        {
          "id": "task_102",
          "date": "Dec 6, 2025",
          "time": "2:00 PM",
          "text": "Meeting with friends",
          "checked": false,
          "reminder": false,
        },
      ],

      "notifications": [
        {
          "id": "noti_201",
          "title": "Yoga reminder",
          "date": "Dec 6, 2025",
          "message": "Do your morning stretching routine!",
        },
      ],

      "reminders": [
        {
          "id": "rem_201",
          "taskId": "task_101",
          "title": "Morning yoga",
          "time": "06:45 AM",
          "date": "Dec 6, 2025",
        },
      ],
    },
  ],
};
