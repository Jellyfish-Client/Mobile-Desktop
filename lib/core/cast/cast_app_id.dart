/// Receiver Chromecast cible.
///
/// On utilise le **Default Media Receiver** de Google (`CC1AD845`), pré-installé
/// sur tous les Chromecasts. C'est l'approche choisie par Streamyfin (client
/// Jellyfin React Native populaire) car elle est plus robuste que le receiver
/// Jellyfin officiel `F007D354` :
///
///   - Pas de dépendance à la web app receiver hébergée par Google.
///   - Pas de problème "mixed content" : le Default Receiver lit juste l'URL
///     fournie, il ne fait pas d'XHR vers le serveur Jellyfin.
///   - Latence d'init quasi nulle (le receiver est déjà chargé).
///
/// Le compromis : c'est l'app qui résout l'URL de stream localement (via
/// `getPostedPlaybackInfo` + DeviceProfile Chromecast) et qui gère son propre
/// reporting `/Sessions/Playing*` côté serveur Jellyfin.
const String kCastReceiverAppId = 'CC1AD845';
