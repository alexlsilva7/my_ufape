# Melhorias nos Scripts do Fluxo de Histórico Escolar

## Análise dos Scripts Atuais

### 1. scriptHistoricoEscolar() (linha 408)

**Problemas Identificados:**
- Usa Promise mas não tem timeout definido
- Busca apenas por texto exato "Histórico Escolar" sem fallback
- Não verifica se o iframe está pronto antes de buscar os links
- Não tem retry em caso de falha temporária

**Impacto:**
- Pode travar indefinidamente se o link não for encontrado
- Falha se houver variação no texto do link
- Pode tentar acessar elementos antes do DOM estar pronto

### 2. waitForSchoolHistoryPageReadyScript() (linha 411)

**Problemas Identificados:**
- Verificação muito genérica (apenas procura por "Componente Curricular" em qualquer tabela)
- Não verifica se a tabela de dados está completamente carregada
- Pode retornar `true` antes da página estar totalmente renderizada
- Não valida a estrutura esperada da página

**Impacto:**
- Pode iniciar extração antes dos dados estarem disponíveis
- Falsos positivos se houver texto similar em outras partes da página
- Dados incompletos ou corrompidos na extração

### 3. extractSchoolHistoryScript() (linha 414-534)

**Problemas Identificados:**
- Script muito longo e complexo (120+ linhas)
- Múltiplos pontos de falha sem tratamento específico
- Não tem logs intermediários para debug
- Parsing pode falhar silenciosamente em alguns casos
- Lógica de parsing misturada com lógica de navegação DOM

**Impacto:**
- Difícil de debugar quando algo falha
- Manutenção complexa
- Performance pode ser afetada por múltiplas iterações
- Erros podem passar despercebidos

## Melhorias Propostas

### 1. Melhorar scriptHistoricoEscolar()

```javascript
static String scriptHistoricoEscolar() => r"""
new Promise((resolve, reject) => {
  const maxTries = 150; // 3 segundos (150 * 20ms)
  let tries = 0;
  
  const interval = setInterval(() => {
    tries++;
    
    const iframe = document.getElementById('Conteudo');
    if (!iframe || !iframe.contentDocument) {
      if (tries >= maxTries) {
        clearInterval(interval);
        reject('ERROR: Iframe not ready after timeout');
      }
      return;
    }
    
    const links = iframe.contentDocument.querySelectorAll('a.default');
    for (const link of links) {
      const linkText = link.innerText.trim();
      // Busca mais flexível - aceita variações
      if (linkText.includes('Histórico') && linkText.includes('Escolar')) {
        clearInterval(interval);
        try {
          link.click();
          resolve('SUCCESS: Histórico Escolar link clicked');
        } catch (e) {
          reject('ERROR: Failed to click link - ' + e.toString());
        }
        return;
      }
    }
    
    if (tries >= maxTries) {
      clearInterval(interval);
      reject('ERROR: "Histórico Escolar" link not found after ' + maxTries + ' attempts');
    }
  }, 20);
});
""";
```

**Benefícios:**
- Timeout definido (3 segundos)
- Busca mais flexível por palavras-chave
- Verifica se iframe está pronto antes de buscar
- Mensagens de erro mais descritivas

### 2. Melhorar waitForSchoolHistoryPageReadyScript()

```javascript
static String waitForSchoolHistoryPageReadyScript() => r"""
(function() {
  try {
    const iframe = document.getElementById('Conteudo');
    if (!iframe || !iframe.contentDocument) {
      return false;
    }
    
    const doc = iframe.contentDocument;
    
    // Verifica se o container principal existe
    const mainContainer = doc.querySelector('div#content');
    if (!mainContainer) {
      return false;
    }
    
    // Verifica se há pelo menos uma tabela com marcador de período
    const periodMarkers = Array.from(mainContainer.querySelectorAll('table')).filter(
      table => table.innerText.trim().startsWith('Período:')
    );
    
    if (periodMarkers.length === 0) {
      return false;
    }
    
    // Verifica se há pelo menos uma tabela de conteúdo após o marcador
    const firstMarker = periodMarkers[0];
    let contentTable = firstMarker.nextElementSibling;
    while (contentTable && contentTable.tagName !== 'TABLE') {
      contentTable = contentTable.nextElementSibling;
    }
    
    // Verifica se a tabela de conteúdo tem dados
    if (!contentTable || contentTable.querySelectorAll('tr').length === 0) {
      return false;
    }
    
    // Verifica se a tabela de resumo existe (Média Geral)
    const hasSummary = Array.from(mainContainer.querySelectorAll('table')).some(
      table => table.innerText.includes('Média Geral:')
    );
    
    // Página está pronta se tem períodos E (tem dados OU tem resumo)
    return contentTable.querySelectorAll('tr').length > 0 || hasSummary;
    
  } catch (e) {
    console.error('Error checking page ready:', e);
    return false;
  }
})();
""";
```

**Benefícios:**
- Verificações mais específicas e robustas
- Valida estrutura completa da página
- Garante que dados estão disponíveis antes de extrair
- Tratamento de erros com try-catch
- Logs de erro para debug

### 3. Melhorar extractSchoolHistoryScript()

**Estratégia de Melhoria:**

1. **Separar em funções menores:**
   - `parseValue()` - já existe, manter
   - `splitCodeAndName()` - já existe, manter
   - `extractPeriodData()` - nova função para extrair dados de um período
   - `extractSummaryData()` - nova função para extrair resumo geral

2. **Adicionar validações intermediárias:**
   - Verificar se elementos existem antes de acessar
   - Validar estrutura de dados antes de processar
   - Retornar erros específicos para cada etapa

3. **Melhorar logging:**
   - Adicionar console.log em pontos críticos
   - Incluir informações sobre quantos períodos foram encontrados
   - Logar avisos para dados ausentes (não críticos)

4. **Otimizar performance:**
   - Reduzir número de querySelectorAll
   - Cachear seletores frequentemente usados
   - Usar early returns para evitar processamento desnecessário

```javascript
static String extractSchoolHistoryScript() => r'''
function parseSchoolHistory() {
  try {
    console.log('[SIGA] Iniciando extração do histórico escolar...');
    
    // === FUNÇÕES AUXILIARES ===
    const parseValue = (text) => {
      if (!text) return null;
      const cleanedText = text.trim();
      if (cleanedText === '' || cleanedText === '-') return null;
      const num = parseFloat(cleanedText.replace(',', '.'));
      return isNaN(num) ? cleanedText : num;
    };

    const splitCodeAndName = (rawName) => {
      const trimmedName = rawName.trim();
      const match = trimmedName.match(/^([A-Z0-9]+)\s*-\s*(.*)$/);
      if (match && match.length === 3) {
        return { code: match[1].trim(), name: match[2].trim() };
      }
      return { code: 'N/A', name: trimmedName };
    };

    // === OBTER DOCUMENTO ===
    let iframeDoc;
    const iframe = document.getElementById('Conteudo');
    
    if (iframe && iframe.contentDocument) {
      iframeDoc = iframe.contentDocument;
    } else {
      iframeDoc = document;
    }

    // === VALIDAR CONTAINER PRINCIPAL ===
    const mainContainer = iframeDoc.querySelector('div#content');
    if (!mainContainer) {
      console.error('[SIGA] Container principal não encontrado');
      return JSON.stringify({ 
        error: "Container principal '#content' não foi encontrado." 
      });
    }

    console.log('[SIGA] Container principal encontrado');

    // === EXTRAIR PERÍODOS ===
    const allPeriods = [];
    const periodMarkers = Array.from(mainContainer.querySelectorAll('table')).filter(
      table => table.innerText.trim().startsWith('Período:')
    );

    console.log(`[SIGA] Encontrados ${periodMarkers.length} períodos`);

    for (let i = 0; i < periodMarkers.length; i++) {
      const marker = periodMarkers[i];
      const periodName = marker.querySelector('.editPesquisa.fonte8pt')?.innerText.trim();
      
      if (!periodName) {
        console.warn(`[SIGA] Período ${i + 1}: nome não encontrado, pulando...`);
        continue;
      }

      console.log(`[SIGA] Processando período: ${periodName}`);

      const periodObject = {
        period: periodName,
        subjects: [],
        periodAverage: null,
        periodCoefficient: null,
      };

      // Buscar tabela de conteúdo
      let contentTable = marker.nextElementSibling;
      while (contentTable && contentTable.tagName !== 'TABLE') {
        contentTable = contentTable.nextElementSibling;
      }

      if (!contentTable) {
        console.warn(`[SIGA] Período ${periodName}: tabela de conteúdo não encontrada`);
        continue;
      }

      const rows = Array.from(contentTable.querySelectorAll('tr'));
      console.log(`[SIGA] Período ${periodName}: ${rows.length} linhas encontradas`);
      
      // Caso especial: período com status especial (ex: "Trancamento")
      if (rows.length === 1 && rows[0].cells.length === 1) {
        const specialStatusText = rows[0].innerText.trim();
        periodObject.subjects.push({
          code: 'N/A',
          name: specialStatusText,
          absences: 0,
          workload: 0,
          credits: 0,
          finalGrade: null,
          status: specialStatusText,
        });
        console.log(`[SIGA] Período ${periodName}: status especial - ${specialStatusText}`);
      } else {
        // Processar disciplinas normais
        let subjectCount = 0;
        for (const row of rows) {
          const cells = row.cells;
          
          // Linha de disciplina (6 colunas com dados)
          if (cells.length === 6 && cells[0].querySelector('.editPesquisa.fonte8pt')) {
            const { code, name } = splitCodeAndName(cells[0].innerText);
            periodObject.subjects.push({
              code: code,
              name: name,
              absences: parseValue(cells[1].innerText),
              workload: parseValue(cells[2].innerText),
              credits: parseValue(cells[3].innerText),
              finalGrade: parseValue(cells[4].innerText),
              status: parseValue(cells[5].innerText),
            });
            subjectCount++;
          } 
          // Linha de média do período
          else if (row.innerText.includes('Média do Período:')) {
            periodObject.periodAverage = parseValue(cells[cells.length - 1].innerText);
            console.log(`[SIGA] Período ${periodName}: média = ${periodObject.periodAverage}`);
          } 
          // Linha de coeficiente do período
          else if (row.innerText.includes('Coeficiente de Rendimento Escolar no Período:')) {
            periodObject.periodCoefficient = parseValue(cells[cells.length - 1].innerText);
            console.log(`[SIGA] Período ${periodName}: CR = ${periodObject.periodCoefficient}`);
          }
        }
        console.log(`[SIGA] Período ${periodName}: ${subjectCount} disciplinas extraídas`);
      }
      
      allPeriods.push(periodObject);
    }

    // === EXTRAIR RESUMO GERAL ===
    console.log('[SIGA] Extraindo resumo geral...');
    let overallAverage = null;
    let overallCoefficient = null;
    
    const summaryTable = Array.from(mainContainer.querySelectorAll('table')).find(
      table => table.innerText.includes('Média Geral:')
    );

    if (summaryTable) {
      const rows = summaryTable.querySelectorAll('tr');
      rows.forEach(row => {
        if (row.innerText.includes('Média Geral:')) {
          overallAverage = parseValue(row.cells[row.cells.length - 1].innerText);
          console.log(`[SIGA] Média Geral: ${overallAverage}`);
        } else if (row.innerText.includes('Coeficiente de Rendimento Escolar Geral:')) {
          overallCoefficient = parseValue(row.cells[row.cells.length - 1].innerText);
          console.log(`[SIGA] CR Geral: ${overallCoefficient}`);
        }
      });
    } else {
      console.warn('[SIGA] Tabela de resumo geral não encontrada');
    }

    console.log(`[SIGA] Extração concluída: ${allPeriods.length} períodos processados`);

    return JSON.stringify({
      periods: allPeriods,
      overallAverage: overallAverage,
      overallCoefficient: overallCoefficient,
    });
    
  } catch (e) {
    console.error('[SIGA] Erro na extração:', e);
    return JSON.stringify({ 
      error: "Erro ao executar script de extração: " + e.toString() 
    });
  }
}

// Executa a função
parseSchoolHistory();
''';
```

**Benefícios:**
- Logs detalhados em cada etapa para debug
- Validações intermediárias evitam erros silenciosos
- Código mais legível e manutenível
- Melhor tratamento de casos especiais
- Performance otimizada com early returns

## Resumo das Melhorias

| Script | Melhorias Principais | Impacto |
|--------|---------------------|---------|
| `scriptHistoricoEscolar` | Timeout, busca flexível, verificação de iframe | Maior confiabilidade |
| `waitForSchoolHistoryPageReadyScript` | Validações específicas, verificação de estrutura | Menos falsos positivos |
| `extractSchoolHistoryScript` | Logs detalhados, validações, código modular | Melhor debugabilidade |

## Próximos Passos

1. Implementar as melhorias no arquivo [`siga_scripts.dart`](lib/data/services/siga/siga_scripts.dart:1)
2. Testar cada script individualmente
3. Testar o fluxo completo de sincronização
4. Monitorar logs para identificar possíveis problemas
5. Ajustar timeouts se necessário baseado em testes reais

## Considerações de Performance

- Os scripts otimizados devem executar em tempo similar ou melhor
- Logs podem ser removidos em produção se necessário
- Timeouts podem ser ajustados baseado na velocidade da rede
- Validações adicionais têm custo mínimo mas aumentam confiabilidade

## Testes Recomendados

1. **Teste com histórico completo** - múltiplos períodos com várias disciplinas
2. **Teste com histórico vazio** - nenhum período cadastrado
3. **Teste com período especial** - trancamento, jubilamento, etc.
4. **Teste com conexão lenta** - verificar se timeouts são adequados
5. **Teste com dados incompletos** - disciplinas sem nota, sem CR, etc.