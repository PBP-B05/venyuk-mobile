import 'package:flutter/material.dart';
import '../models/participant_model.dart'; // Nanti kita buat model ini

class ParticipantTile extends StatelessWidget {
  final Participant participant;
  final bool isCreator; // Cek apakah user yg login adalah pembuat match
  final VoidCallback? onKick; // Fungsi untuk kick user

  const ParticipantTile({
    super.key,
    required this.participant,
    this.isCreator = false,
    this.onKick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Text(
          participant.fullName[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(participant.fullName),
      subtitle: Text(participant.phone),
      trailing: isCreator
          ? IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              tooltip: "Kick Participant",
              onPressed: onKick,
            )
          : null, // Jika bukan creator, tidak ada tombol kick
    );
  }
}