# Plano: Login por biometria e timeout de sessão

> **Status:** planejado — implementar depois da aprovação da versão `1.1.0+22` (target API 36) na Play Store.
> **Estimativa:** 2 a 3 dias (desenvolvimento + testes).
> **Complexidade:** média. A biometria em si é simples; o trabalho maior é mudar a forma como as credenciais são guardadas.

---

## 1. Situação atual

| Ponto | Como está | Onde |
|---|---|---|
| Autenticação | Basic Auth (`usuario:senha` em base64) enviado em **toda** requisição | `lib/services/*_service.dart` |
| Armazenamento da senha | **Texto puro** no `SharedPreferences` (`password`) | `lib/services/auth_service.dart` (`saveInfosFromResponse`) |
| Leitura da senha | 16 services leem `prefs.getString('password')` diretamente (62 ocorrências de `password`/`Basic`) | `lib/services/` |
| "Token" de sessão | É o `first_name`. Se existir no `SharedPreferences`, o usuário é considerado logado | `lib/main.dart` (`verifyToken`) |
| Expiração | Não existe. O servidor não tem sessão e o app nunca expira o login | — |
| Logout | Remove `first_name`, `last_name`, `group`, `id`, mas **não remove `password`** (bug) | `lib/helpers/logout.dart` |

## 2. Decisões pendentes (definir antes de começar)

1. **Tempo de inatividade** até bloquear (sugestão: 5 minutos).
2. **Ação ao expirar:** pedir a biometria de novo, se ativada, **ou** logout completo.
3. **Biometria:** opcional, com o app perguntando após o primeiro login (recomendado), **ou** obrigatória para todos.

## 3. Bibliotecas a adicionar

Apenas adições, sem trocar nada existente. As duas são compatíveis com Flutter 3.38 e minSdk 24.

| Pacote | Uso |
|---|---|
| `flutter_secure_storage` | Guardar usuário e senha no Android Keystore / iOS Keychain |
| `local_auth` | Pedir digital ou reconhecimento facial (mesma API para os dois) |

## 4. Etapas de implementação

### Etapa 1 — Credenciais seguras (pré-requisito; resolve a falha de segurança atual)

1. Criar `lib/services/session_service.dart` centralizando:
   - `saveCredentials(id, password)`, `getPassword()`, `getId()`, `clear()`
   - leitura e gravação via `flutter_secure_storage`.
2. Alterar `AuthService.saveInfosFromResponse` para gravar a senha no `SessionService`, e não mais no `SharedPreferences`.
3. Substituir as leituras de `prefs.getString('password')` nos 16 services por `SessionService`:
   `aniversarios`, `app_version`, `convenios`, `ferias`, `homeoffice`, `periodo`, `sp8010`, `spi010`, `sqb010`, `srf010`, `srh010`, `sx5010`, `sze010`, `sze010_falta_dias`, `szh010`, `auth`.
4. **Migração automática** (no `main()`, antes do `runApp`): se existir `password` no `SharedPreferences`, copiar para o armazenamento seguro e remover do `SharedPreferences`. Assim ninguém é deslogado com a atualização.
5. Corrigir `logout.dart` para chamar `SessionService.clear()`, o que apaga a senha e a preferência de biometria.

### Etapa 2 — Login por biometria

1. **Android**
   - `android/app/src/main/kotlin/.../MainActivity.kt`: trocar `FlutterActivity` por `FlutterFragmentActivity` (exigido pelo `local_auth`).
   - `AndroidManifest.xml`: adicionar `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>`.
2. **iOS**
   - `ios/Runner/Info.plist`: adicionar `NSFaceIDUsageDescription` com o texto explicando o uso do Face ID.
3. **Fluxo**
   - Após o primeiro login com senha bem-sucedido, se o aparelho suportar biometria (`canCheckBiometrics` / `isDeviceSupported`), perguntar: *"Deseja usar digital/reconhecimento facial nos próximos acessos?"*. Salvar a escolha (`biometria_ativa`).
   - Na abertura do app (`main.dart` / `TransferHome`): se `biometria_ativa` e houver credenciais salvas, mostrar a solicitação de biometria do sistema. Se aprovada, segue para `transfer`; se falhar ou for cancelada, vai para a tela de login.
   - A tela de login continua sempre disponível como alternativa (aparelho sem biometria, biometria alterada, falhas repetidas).
   - Opcional: opção no `menu_drawer.dart` para ativar ou desativar a biometria.

### Etapa 3 — Timeout de sessão (controlado só pelo app)

1. Criar um controlador de sessão, por exemplo `lib/helpers/session_timeout.dart`, com:
   - **Timer de inatividade**, reiniciado a cada toque. Envolver o `MaterialApp` com um `Listener(onPointerDown: ...)`.
   - **Observador do ciclo de vida** (`WidgetsBindingObserver`): ao ir para segundo plano, guardar o horário; ao voltar, se passou do limite, bloquear.
2. Ao expirar, conforme a decisão 2:
   - pedir a biometria de novo (se ativada) e voltar para a tela em que o usuário estava, **ou**
   - chamar `logout(context)` e ir para `login`.
3. Usar uma `GlobalKey<NavigatorState>` no `MaterialApp` para navegar sem depender de um `BuildContext` de tela.

## 5. Arquivos impactados

| Tipo | Arquivos |
|---|---|
| Novos | `lib/services/session_service.dart`, `lib/helpers/session_timeout.dart`, eventualmente uma tela ou diálogo de desbloqueio |
| Alterados | `lib/main.dart`, `lib/screens/login_screen/login_screen.dart`, `lib/helpers/logout.dart`, 16 services em `lib/services/`, `MainActivity.kt`, `AndroidManifest.xml`, `ios/Runner/Info.plist`, `pubspec.yaml` |

## 6. Riscos

| Risco | Mitigação |
|---|---|
| Migração falhar e deslogar todos os usuários | Testar a atualização sobre uma instalação da versão anterior já logada |
| Algum service continuar lendo a senha do `SharedPreferences` | Depois da refatoração, `grep "getString('password')"` em `lib/` deve retornar zero |
| Biometria cadastrada no aparelho mudar | Tratar o erro do `local_auth` e cair na tela de login |
| Timeout disparar no meio de uma operação (ex.: envio de formulário) | Reiniciar o timer também ao iniciar requisições HTTP |

## 7. Roteiro de testes

- [ ] Instalar a versão atual (`1.1.0+22`), logar, atualizar para a nova versão → continua logado e a senha some do `SharedPreferences`.
- [ ] Primeiro login → aparece a pergunta sobre biometria.
- [ ] Biometria ativada → reabrir o app pede digital; cancelar leva ao login.
- [ ] Aparelho sem biometria → nenhuma pergunta, fluxo normal com senha.
- [ ] Inatividade maior que o limite → bloqueio conforme a decisão 2.
- [ ] App em segundo plano por mais tempo que o limite → bloqueio ao voltar.
- [ ] Logout → senha e preferência de biometria apagadas.
- [ ] Testar em Android 16 (API 36) e em uma versão antiga (API 24–30).

**Emulador Android:** cadastrar uma digital em Configurações → Segurança e simular o toque em *Extended controls → Fingerprint*. O reconhecimento facial só pode ser testado em aparelho real.
