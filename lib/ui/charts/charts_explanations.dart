const String mediaGeralMarkdown = '''
## Média Geral

Este card mostra a média aritmética simples de todas as suas notas finais (identificadas como "Média" ou "MF") em todas as disciplinas que você já concluiu.

### Como é calculado?

1.  **Coleta de Notas**: O sistema busca a nota final de cada disciplina em seu histórico.
2.  **Soma**: Todas essas notas são somadas.
3.  **Divisão**: O resultado da soma é dividido pelo número total de disciplinas com nota final encontrada.

**Exemplo**: Se você teve as notas `8.0`, `9.5` e `6.5` em três disciplinas, o cálculo será:

` (8.0 + 9.5 + 6.5) / 3 = 8.0 `

**Observação**: Este cálculo é uma média simples e não leva em conta o peso (carga horária ou créditos) de cada disciplina.
''';

const String taxaDeAprovacaoMarkdown = '''
## Taxa de Aprovação

Este indicador representa a porcentagem de disciplinas em que você foi aprovado em relação ao total de disciplinas que já foram finalizadas (ou seja, que não estão "em andamento").

### Como é calculado?

A fórmula é:

` (Total de Disciplinas Aprovadas / Total de Disciplinas Concluídas) * 100 `

Onde:
-   **Total de Disciplinas Aprovadas**: Conta todas as disciplinas com status "APROVADO".
-   **Total de Disciplinas Concluídas**: É a soma das disciplinas "APROVADAS" e "REPROVADAS".

**Exemplo**: Se você concluiu 10 disciplinas, sendo 8 aprovadas e 2 reprovadas, o cálculo será:

` (8 / 10) * 100 = 80% `

Disciplinas que você está cursando atualmente não entram neste cálculo para não distorcer a sua taxa de sucesso histórica.
''';

const String distribuicaoSituacoesMarkdown = '''
## Distribuição de Situações

Este gráfico de pizza mostra a proporção de todas as suas disciplinas divididas em três categorias:

1.  **Aprovadas**: Disciplinas que você concluiu com sucesso.
2.  **Cursando**: Disciplinas em que você está matriculado no período atual.
3.  **Reprovadas**: Disciplinas em que você não obteve a aprovação.

### Como interpretar?

-   Uma fatia verde **(Aprovadas)** grande indica um bom histórico de sucesso.
-   A fatia laranja **(Cursando)** representa seu esforço atual.
-   A fatia vermelha **(Reprovadas)** aponta para as dificuldades passadas, que podem ser oportunidades de aprendizado.

O gráfico oferece uma visão rápida do seu percurso acadêmico geral, equilibrando o passado e o presente.
''';

const String evolucaoMediasMarkdown = '''
## Evolução das Médias por Período

Este gráfico de linha mostra como a sua média de notas variou ao longo dos períodos letivos.

### Como é calculado?

-   Para cada período, é calculada a **média aritmética simples** de todas as notas finais das disciplinas que você cursou naquele período.
-   Cada ponto no gráfico representa a média de um período específico.
-   A linha que conecta os pontos ajuda a visualizar a tendência do seu desempenho: se ele está melhorando, piorando ou se mantendo estável ao longo do tempo.

### Como interpretar?

-   **Linha ascendente**: Indica que seu desempenho está melhorando a cada período.
-   **Linha descendente**: Sugere uma queda no desempenho que pode merecer atenção.
-   **Linha estável**: Mostra consistência nas suas médias.
''';

const String correlacaoCargaMediaMarkdown = '''
## Correlação: Carga vs. Média

Este gráfico de dispersão (scatter plot) analisa se existe uma relação entre o **número de disciplinas** que você cursa em um período (carga de trabalho) e a sua **média de notas** naquele mesmo período.

### Como interpretar o coeficiente `r`?

O valor `r` (Coeficiente de Correlação de Pearson) varia de -1 a 1:

-   **`r` próximo de 1**: Correlação positiva forte. Geralmente, quanto mais disciplinas você cursa, **maior** é a sua média.
-   **`r` próximo de -1**: Correlação negativa forte. Geralmente, quanto mais disciplinas você cursa, **menor** é a sua média. Isso pode indicar sobrecarga.
-   **`r` próximo de 0**: Sem correlação aparente. O número de disciplinas não parece influenciar sua média.

Cada ponto no gráfico representa um período, onde o eixo X é o número de disciplinas e o eixo Y é a sua média.
''';

const String distribuicaoNotasMarkdown = '''
## Distribuição de Notas

Este gráfico de barras mostra a frequência de suas notas finais, agrupadas em faixas de pontuação.

### Como é calculado?

-   O sistema verifica a nota final de cada disciplina concluída.
-   Cada barra representa uma faixa de notas (ex: "0-2", "2-4", ..., "8-10").
-   A altura da barra indica **quantas disciplinas** tiveram uma nota final dentro daquela faixa.

### Como interpretar?

-   Barras mais altas nas faixas de notas maiores (ex: "8-10") indicam um excelente desempenho predominante.
-   Barras mais altas nas faixas de notas menores podem indicar áreas que precisam de mais atenção.

Este gráfico ajuda a visualizar rapidamente qual é a sua faixa de desempenho mais comum.
''';

const String topDesempenhosMarkdown = '''
## Top 10 Melhores Desempenhos

Esta lista classifica as 10 disciplinas em que você obteve as **maiores notas finais**.

### Como é calculado?

-   O sistema coleta a nota final de todas as disciplinas que você já concluiu.
-   As disciplinas são ordenadas da maior para a menor nota.
-   As 10 primeiras são exibidas aqui.

Esta seção destaca seus pontos fortes e as áreas em que você teve mais sucesso.
''';

const String melhorPeriodoMarkdown = '''
## Melhor Período Acadêmico

Este card destaca seus períodos de maior sucesso com base em dois critérios diferentes:

1.  **Melhor Média**: O período em que a média aritmética de suas notas finais foi a mais alta.
2.  **Mais Aprovadas**: O período em que você conseguiu aprovação no maior número de disciplinas.

### Por que dois critérios?

Às vezes, o período com a melhor média não é o mesmo em que você cursou e passou em mais matérias. Comparar os dois pode trazer insights:

-   Você rende mais com menos disciplinas e notas maiores?
-   Ou você consegue lidar com uma carga maior, mesmo que a média oscile um pouco?

Analisar esses dois destaques ajuda a entender melhor seu perfil de estudo.
''';

const String insightsMarkdown = '''
## Insights e Recomendações

Esta seção oferece interpretações e conselhos automatizados com base nos seus dados de desempenho.

### Como funciona?

O sistema analisa um conjunto de métricas, como:

-   **Taxa de Aprovação**: Se está alta ou baixa.
-   **Média Geral**: Se está acima ou abaixo de certos patamares (ex: 7.0).
-   **Consistência**: Se suas notas variam muito (desvio padrão alto).
-   **Tendência**: Se seu desempenho recente está melhorando ou piorando em relação ao passado.

Com base nesses fatores, um ou mais insights são selecionados para te dar um feedback rápido sobre sua trajetória acadêmica e sugerir pontos de foco.
''';

const String tendenciaDesempenhoMarkdown = '''
## Tendência de Desempenho

Este card mostra se o seu desempenho acadêmico está melhorando ou piorando em relação ao período anterior.

### Como é calculado?

-   O sistema compara a **média do último período** com a **média do penúltimo período**.
-   Se a diferença for positiva, seu desempenho está em melhoria.
-   Se a diferença for negativa, há uma queda no desempenho que merece atenção.

### Como interpretar?

-   **Desempenho em Melhoria** (ícone verde com seta para cima): Parabéns! Sua média aumentou em relação ao período anterior. Continue assim!
-   **Atenção ao Desempenho** (ícone laranja com seta para baixo): Sua média diminuiu. Pode ser um sinal para revisar seus métodos de estudo ou gerenciamento de tempo.

Este indicador ajuda você a acompanhar sua evolução recente e tomar ações corretivas quando necessário.
''';

const String consistenciaMarkdown = '''
## Análise de Consistência

Este card avalia o quão estáveis são suas notas ao longo do tempo.

### Como é calculado?

O sistema calcula o **desvio padrão** de todas as suas notas finais:

-   **Desvio padrão baixo (< 1.5)**: Suas notas são consistentes e previsíveis.
-   **Desvio padrão alto (≥ 1.5)**: Suas notas variam bastante entre disciplinas.

### Como interpretar?

-   **Consistente** (ícone verde): Você mantém um desempenho estável. Isso indica que você tem um método de estudo confiável.
-   **Variável** (ícone azul): Suas notas oscilam bastante. Isso pode indicar que você se destaca em algumas áreas e tem dificuldades em outras, ou que fatores externos estão afetando seu desempenho.

A consistência não é necessariamente melhor que a variabilidade - depende do seu perfil. Mas entender seu padrão ajuda no planejamento.
''';

const String progressaoMarkdown = '''
## Progressão Geral

Este card mostra a evolução do seu desempenho desde o primeiro período até o mais recente.

### Como é calculado?

-   Compara a **média do primeiro período** com a **média do último período**.
-   Calcula a diferença absoluta e a variação percentual.

### Como interpretar?

-   **Seta para cima (verde)**: Sua média aumentou ao longo do tempo. Você está evoluindo!
-   **Seta para baixo (vermelha)**: Sua média diminuiu. Pode ser útil refletir sobre o que mudou.
-   **Linha horizontal (cinza)**: Sua média se manteve praticamente igual.

**Exemplo**: Se você começou com média 6.5 e agora está com 8.0, a progressão mostra +1.5 pontos (+23.1%).

Este indicador oferece uma visão de longo prazo da sua trajetória acadêmica.
''';
