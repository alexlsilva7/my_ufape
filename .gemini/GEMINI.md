Ao gerar código Flutter, siga estas regras de performance:

WIDGETS:
- NUNCA crie métodos que retornam widgets (ex: Widget _buildAppBar())
- SEMPRE extraia widgets para classes StatelessWidget ou StatefulWidget separadas
- Use const constructors sempre que possível
- Cada componente visual deve ser um widget independente, não um método

PERFORMANCE:
- Use const onde aplicável (const Text(), const SizedBox())
- Use ListView.builder para listas longas
- Evite operações pesadas dentro do método build()

EXEMPLO CORRETO:
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: const ContentWidget(),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Título'));
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

EXEMPLO INCORRETO (NÃO FAÇA):
class MyScreen extends StatelessWidget {
  Widget _buildAppBar() { // ❌ ERRADO - Nunca use métodos para widgets
    return AppBar(title: Text('Título'));
  }
}

MOTIVO: Métodos impedem otimizações do Flutter e causam rebuilds desnecessários.
Widgets separados permitem que o framework pule reconstruções quando nada muda.

Responda em Português-Brasil.

---

### Regras de Estilo de Código

- **Cores e Opacidade**: Em vez de usar o método `.withOpacity()`, que é depreciado, utilize o método de extensão `.withValues(alpha: ...)`. 
  - **Exemplo ruim:** `Colors.blue.withOpacity(0.8)`
  - **Exemplo bom:** `Colors.blue.withValues(alpha: 0.8)`