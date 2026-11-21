import 'package:material_ui/material_ui.dart';

/// Tipos de conteúdo que o usuário pode criar.
///
/// Cada valor carrega metadados de exibição (label, ícone, descrição) para
/// serem usados pela UI de seleção sem acoplamento a widgets específicos.
enum ContentType {
  post(
    label: 'Publicação',
    description: 'Texto, links e hashtags',
    icon: Icons.edit_outlined,
    activeIcon: Icons.edit_rounded,
  ),
  photo(
    label: 'Foto',
    description: 'Imagens da galeria ou câmera',
    icon: Icons.photo_outlined,
    activeIcon: Icons.photo_rounded,
  ),
  video(
    label: 'Vídeo',
    description: 'Vídeo da galeria ou câmera',
    icon: Icons.videocam_outlined,
    activeIcon: Icons.videocam_rounded,
  ),
  audio(
    label: 'Áudio',
    description: 'Grave ou importe um clipe',
    icon: Icons.mic_outlined,
    activeIcon: Icons.mic_rounded,
  ),
  story(
    label: 'Story',
    description: 'Desaparece em 24 horas',
    icon: Icons.auto_stories_outlined,
    activeIcon: Icons.auto_stories_rounded,
  ),
  article(
    label: 'Artigo',
    description: 'Texto longo com título',
    icon: Icons.article_outlined,
    activeIcon: Icons.article_rounded,
  ),
  poll(
    label: 'Enquete',
    description: 'Faça uma pergunta com opções',
    icon: Icons.poll_outlined,
    activeIcon: Icons.poll_rounded,
  ),
  event(
    label: 'Evento',
    description: 'Convite com data e local',
    icon: Icons.event_outlined,
    activeIcon: Icons.event_rounded,
  ),
  live(
    label: 'Live',
    description: 'Transmissão ao vivo',
    icon: Icons.live_tv_outlined,
    activeIcon: Icons.live_tv_rounded,
  );

  const ContentType({
    required this.label,
    required this.description,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String description;
  final IconData icon;
  final IconData activeIcon;
}
