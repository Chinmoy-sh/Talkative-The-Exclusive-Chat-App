# Assets Structure

assets/
  images/
    logo/
      app_logo.png
      app_logo_dark.png
      app_logo_transparent.png
    illustrations/
      onboarding_1.svg
      onboarding_2.svg
      onboarding_3.svg
      welcome_illustration.svg
      empty_chat.svg
      no_internet.svg
    avatars/
      default_avatar.png
      placeholder_avatar.png
    backgrounds/
      chat_background.jpg
      login_background.jpg
      gradient_bg.png
    icons/
      chat_icon.svg
      group_icon.svg
      call_icon.svg
      video_call_icon.svg
      status_icon.svg
      settings_icon.svg
      profile_icon.svg
      notification_icon.svg
      security_icon.svg
      privacy_icon.svg
      help_icon.svg
      about_icon.svg
      logout_icon.svg
      dark_mode_icon.svg
      light_mode_icon.svg
      backup_icon.svg
      storage_icon.svg
      language_icon.svg
      theme_icon.svg
      keyboard_icon.svg
      media_icon.svg
      document_icon.svg
      location_icon.svg
      camera_icon.svg
      gallery_icon.svg
      microphone_icon.svg
      attachment_icon.svg
      emoji_icon.svg
      send_icon.svg
      back_icon.svg
      forward_icon.svg
      delete_icon.svg
      copy_icon.svg
      share_icon.svg
      save_icon.svg
      download_icon.svg
      upload_icon.svg
      search_icon.svg
      filter_icon.svg
      sort_icon.svg
      menu_icon.svg
      close_icon.svg
      check_icon.svg
      cross_icon.svg
      warning_icon.svg
      error_icon.svg
      success_icon.svg
      info_icon.svg
    ui/
      splash_logo.png
      loading_spinner.gif
      success_checkmark.svg
      error_cross.svg
      warning_triangle.svg
  fonts/
    Poppins/
      Poppins-Thin.ttf (100)
      Poppins-ExtraLight.ttf (200)
      Poppins-Light.ttf (300)
      Poppins-Regular.ttf (400)
      Poppins-Medium.ttf (500)
      Poppins-SemiBold.ttf (600)
      Poppins-Bold.ttf (700)
      Poppins-ExtraBold.ttf (800)
      Poppins-Black.ttf (900)
    Inter/
      Inter-Thin.ttf (100)
      Inter-ExtraLight.ttf (200)
      Inter-Light.ttf (300)
      Inter-Regular.ttf (400)
      Inter-Medium.ttf (500)
      Inter-SemiBold.ttf (600)
      Inter-Bold.ttf (700)
      Inter-ExtraBold.ttf (800)
      Inter-Black.ttf (900)
    Roboto/
      Roboto-Thin.ttf (100)
      Roboto-Light.ttf (300)
      Roboto-Regular.ttf (400)
      Roboto-Medium.ttf (500)
      Roboto-Bold.ttf (700)
      Roboto-Black.ttf (900)
  animations/
    lottie/
      splash_animation.json
      loading_animation.json
      success_animation.json
      error_animation.json
      typing_animation.json
      sending_message.json
      received_message.json
      online_indicator.json
      call_ringing.json
      call_connecting.json
      call_ended.json
      emoji_reaction.json
      heart_animation.json
      confetti_animation.json
      wave_animation.json
    rive/
      interactive_button.riv
      chat_bubble.riv
      profile_avatar.riv
      menu_transition.riv
  sounds/
    notifications/
      message_received.wav
      message_sent.wav
      call_incoming.wav
      call_outgoing.wav
      call_ended.wav
      notification_default.wav
      notification_important.wav
      typing_sound.wav
    ui/
      button_click.wav
      swipe_sound.wav
      pop_sound.wav
      success_sound.wav
      error_sound.wav
      camera_shutter.wav
    ambient/
      chat_background_soft.mp3
      focus_mode.mp3
  videos/
    tutorials/
      app_intro.mp4
      features_overview.mp4
      security_features.mp4
    background/
      login_video_bg.mp4
      splash_video_bg.mp4

NOTES:

- All image files should be provided in multiple resolutions (1x, 2x, 3x) for different screen densities
- SVG files are preferred for icons as they scale perfectly
- Font files should include all required weights and styles
- Lottie animations should be optimized for mobile performance
- Sound files should be compressed and optimized for mobile
- Videos should be compressed and have fallback images
- All assets should follow consistent naming conventions
- Dark mode variants should be provided where applicable
- Accessibility considerations should be included (alt text, etc.)

RECOMMENDED SIZES:

- App Icons: 1024x1024 (for stores), 512x512, 192x192, 144x144, 96x96, 72x72, 48x48
- Splash Logo: 512x512 or vector format
- UI Icons: 24x24, 32x32, 48x48 (or vector)
- Illustrations: Variable, but optimized for target screens
- Background Images: 1920x1080 and mobile variants

LICENSE REQUIREMENTS:

- Ensure all assets have proper licensing for commercial use
- Include attribution files where required
- Consider creating custom assets to avoid licensing issues
- Document asset sources and licenses in ASSETS_LICENSE.md
