/// Dados de conexão com o Supabase.
///
/// Onde pegar: Supabase -> seu projeto -> Project Settings -> API
///  - Project URL
///  - chave "anon" (ou "publishable")
///
/// Pode colocar a chave anon/publishable no app: ela é pública por
/// natureza e quem protege os dados são as regras do schema.sql.
/// NUNCA coloque a chave "service_role" (secreta) aqui.
class SupabaseConfig {
  SupabaseConfig._();

  static const url = 'https://wcwkzkcrnvokwiksolvj.supabase.co';
  static const anonKey = 'sb_publishable_dnujiYgXqX51DO7r2VrmMg_38l_cdwx';

  static bool get configurado =>
      !url.startsWith('COLE_AQUI') && !anonKey.startsWith('COLE_AQUI');
}
