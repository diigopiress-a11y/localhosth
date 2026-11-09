# Perto de Você — localhosth

Landing page mobile-first para consentimento de localização, cadastro voluntário de WhatsApp e painel administrativo privado.

## O que já está no repositório

- Página pública com explicação antes da solicitação de localização.
- Geolocalização solicitada somente após clique; sem rastreamento contínuo.
- Opção de continuar sem compartilhar localização.
- WhatsApp opcional e autorização comercial separada, desmarcada por padrão.
- Consentimento opcional de analytics separado.
- Painel com login Supabase, métricas, histórico, exportação CSV e link para abrir conversa no WhatsApp.
- Política de privacidade inicial.
- SQL com validações e RLS: visitantes podem inserir registros, mas somente administradores cadastrados podem ler os dados.

## Configuração do backend (necessária para funcionar de verdade)

1. Crie um projeto no [Supabase](https://supabase.com/).
2. Abra **SQL Editor** e execute todo o arquivo `supabase/schema.sql`.
3. Em **Project Settings → API**, copie a Project URL e a chave publicável/anon.
4. No `index.html`, preencha `SUPABASE_URL` e `SUPABASE_ANON_KEY`. A chave pública pode estar no navegador; nunca coloque `service_role` ou segredo privado no frontend.
5. Em **Authentication → Users**, crie seu usuário administrador.
6. Copie o UUID desse usuário e execute no SQL Editor:
   `insert into public.admin_users(user_id) values ('UUID_DO_SEU_USUARIO');`
7. Publique o repositório com GitHub Pages, Vercel ou outro host estático com HTTPS. Geolocalização exige contexto seguro (HTTPS ou localhost).
8. Abra `/?admin=1` para entrar no painel.

## Como funciona o contato

O site não consegue descobrir automaticamente o número do chip ou ler contatos do celular. A pessoa precisa informar o WhatsApp e marcar a autorização específica. O painel só mostra o link de contato quando há número e autorização. O botão abre uma conversa manual no WhatsApp; não há disparo automático nesta versão. Para mensagens automáticas, será necessária integração no servidor com a WhatsApp Business Platform, modelos aprovados quando aplicável, gestão de opt-out e credenciais guardadas em secrets.

## Privacidade e segurança — antes de produção

- Atualize `privacidade.html` com a identidade e o canal de contato do controlador, finalidades exatas e prazos de retenção.
- Configure um processo para atender pedidos de acesso, correção, exclusão e revogação.
- Restrinja criação de usuários administrativos e proteja a conta com MFA.
- A política SQL impede leitura pública; revise as políticas antes de alterar permissões.
- A localização pode ser dado pessoal. Colete somente quando necessária e com informação clara.
- O aceite de analytics está separado, mas esta versão ainda não instala cookies de terceiros nem implementa analytics avançado.
- Não há integração de envio automático de WhatsApp.

## Teste local

Sirva a pasta por um servidor local (por exemplo, `python -m http.server 8000`) e acesse `http://localhost:8000`. Para testar geolocalização em produção, use HTTPS.
