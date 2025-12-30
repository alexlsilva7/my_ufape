import 'dart:core';

class SigaScripts {
  /// Retorna script para login. Passar valores já escapados.
  static String loginScript(String user, String pass) {
    return "(function(){try{var u=document.getElementById('cpf')||document.getElementsByName('cpf')[0]||null;var p=document.getElementById('txtPassword')||document.getElementsByName('txtPassword')[0]||null;if(u)u.value='$user';if(p)p.value='$pass';var btn=document.getElementById('btnEntrar');if(btn){btn.click();return;}var form=document.getElementById('formulario')||document.forms[0];if(form)form.submit();}catch(e){} })();";
  }

  /// Script para aplicar estilos customizados na página de login do SIGA
  static const String loginPageStylesScript = """
  (function() {
      'use strict';

      // 1. Função para limpar a interface
      function limparInterface() {
          const seletoresParaRemover = [
              '[id^="subviewTopo:"]', '.coluna-esquerda', '.Rodape', '#espacoVazioRodape',
              'div[layout="block"]', '#divAvisoNavegador', '#divAvisoFirefox25',
              '#containerAcessibilidade', '#conteinerAjuda'
          ];
          seletoresParaRemover.forEach(seletor => {
              const elemento = document.querySelector(seletor);
              if (elemento) elemento.style.display = 'none';
          });
      }

      // 2. Função para aplicar os estilos corrigidos
      function aplicarEstilosResponsivos() {
          const estiloAntigo = document.getElementById('estilo-responsivo-login');
          if (estiloAntigo) estiloAntigo.remove();

          const css = `
              /* -------------------------------------------------- */
              /* 1. RESET E PREPARAÇÃO DOS CONTAINERS PRINCIPAIS    */
              /* -------------------------------------------------- */

              body {
                  display: flex !important;
                  justify-content: center !important;
                  align-items: center !important;
                  height: 100vh !important;
                  margin: 0 !important;
                  background-color: #f0f2f5 !important;
                  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif !important;
              }

              /* ✨ CORREÇÃO PRINCIPAL: Neutraliza os estilos problemáticos de #areaTotal */
              #areaTotal {
                  width: 100% !important;
                  min-height: auto !important; /* Remove a altura mínima conflitante */
                  margin: 0 !important;       /* Remove a margem negativa */
                  overflow: visible !important; /* Evita que o conteúdo seja cortado */
                  display: flex !important;
                  justify-content: center !important;
                  align-items: center !important; /* Centraliza o formulário verticalmente dentro dele */
              }

              .Conteudo {
                  width: 100% !important;
                  display: flex !important;
                  justify-content: center !important;
              }

              /* -------------------------------------------------- */
              /* 2. ESTILOS PARA CELULAR (MOBILE-FIRST)             */
              /* -------------------------------------------------- */

              .login.ui-corner-all {
                  width: 100% !important;
                  background-color: transparent !important; /* Fundo transparente no celular */
                  padding: 0 7vw !important;
                  box-sizing: border-box !important;
                  border: none !important;
                  box-shadow: none !important;
              }

              .login.ui-corner-all label {
                  font-size: 1rem !important;
                  font-weight: 600 !important;
                  margin-bottom: 10px !important;
                  display: block !important;
                  color: #333 !important;
              }

              .login.ui-corner-all input[type="text"],
              .login.ui-corner-all input[type="password"] {
                  width: 100% !important;
                  padding: 18px 16px !important;
                  margin-bottom: 24px !important;
                  font-size: 1.1rem !important;
                  border: 1px solid #ccc !important;
                  border-radius: 8px !important;
                  box-sizing: border-box !important;
              }

              .login.ui-corner-all .esqueceuSenha {
                  display: block !important;
                  text-align: center !important;
                  margin: 20px 0 !important;
                  font-size: 0.95rem !important;
                  color: #007bff !important;
              }

              .login.ui-corner-all .btEntrar {
                  width: 100% !important;
                  padding: 18px !important;
                  font-size: 1.15rem !important;
                  font-weight: bold !important;
                  border: none !important;
                  border-radius: 8px !important;
                  background-color: #2c8b2c !important;
                  color: white !important;
              }

              /* -------------------------------------------------- */
              /* 3. ESTILOS PARA TELAS MAIORES (TABLET/DESKTOP)     */
              /* -------------------------------------------------- */

              @media screen and (min-width: 600px) {
                  .login.ui-corner-all {
                      width: 90% !important;
                      max-width: 420px !important;
                      background-color: #ffffff !important;
                      padding: 3rem !important;
                      border: 1px solid #ddd !important;
                      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1) !important;
                      border-radius: 12px !important;
                  }
              }
          `;

          const style = document.createElement('style');
          style.id = 'estilo-responsivo-login';
          style.type = 'text/css';
          style.appendChild(document.createTextNode(css));
          document.head.appendChild(style);
      }

      limparInterface();
      aplicarEstilosResponsivos();

  })();
  """;

  static String scriptGoHome() =>
      "document.getElementById('menuTopo:imageHome').click();";

  static String checkLoginScript() =>
      "document.getElementById('lblNomePessoa') != null;";

  static String checkAuthErrorScript() {
    return """
    (function() {
      const listItems = document.querySelectorAll('li');
      for (let i = 0; i < listItems.length; i++) {
        if (listItems[i].innerText.trim() === 'Nome de usuário ou senha inválida!') {
            return true;
        }
      }
      return false;
    })();
    """;
  }

  /// Verifica se há mensagem de erro de CAPTCHA ou se o widget está visível
  static String checkCaptchaErrorScript() {
    return """
    (function() {
      const bodyText = document.body.innerText;
      // Verifica mensagem de texto
      if (bodyText.includes('Captcha Inválido') || bodyText.includes('texto da imagem incorreto')) {
        return true;
      }
      
      // Verifica se o widget do reCAPTCHA está presente e visível
      const captchaWidget = document.getElementById('widget-captcha');
      if (captchaWidget && captchaWidget.offsetParent !== null) {
         // Às vezes o widget existe mas não foi ativado, verifica se tem iframe dentro
         if(captchaWidget.querySelector('iframe')) {
            return true;
         }
      }
      
      return false;
    })();
    """;
  }

  /// Verifica se o CAPTCHA foi resolvido com sucesso (checkmark visível)
  static String checkCaptchaCompletedScript() {
    return """
    (function() {
      // 1. Verifica se o checkmark do reCAPTCHA está presente
      const checkmark = document.querySelector('.recaptcha-checkbox-checkmark');
      if (checkmark) {
        // O checkmark existe, mas precisamos verificar se está visível
        // Quando resolvido, o elemento tem estilo que o torna visível
        const style = window.getComputedStyle(checkmark);
        if (style.display !== 'none' && style.visibility !== 'hidden') {
          return true;
        }
      }
      
      // 2. Verifica também pelo aria-checked do checkbox do reCAPTCHA
      const checkbox = document.querySelector('.recaptcha-checkbox[aria-checked="true"]');
      if (checkbox) {
        return true;
      }
      
      // 3. Verifica se a mensagem de sucesso do reCAPTCHA está visível
      const successBanner = document.querySelector('.rc-anchor-pt a[href*="google.com/recaptcha"]');
      if (successBanner) {
        const anchor = successBanner.closest('.rc-anchor');
        if (anchor && anchor.classList.contains('rc-anchor-normal')) {
          const checkedBox = anchor.querySelector('[aria-checked="true"]');
          if (checkedBox) return true;
        }
      }
      
      return false;
    })();
    """;
  }

  /// CSS para limpar a tela de login e focar no CAPTCHA
  /// Este substitui ou complementa o `loginPageStylesScript`
  static const String cleanLoginPageForCaptchaScript = """
  (function() {
      'use strict';
      
      // Remove elementos desnecessários
      const toRemove = [
        '#subviewTopo\\\\:j_id_jsp_1157490793_1pc2', // Topo antigo
        '#areaTotal > div.wrapper-box-topo', // Topo novo
        '#j_id_jsp_1880941391_4', // Coluna esquerda (avisos, menu lateral)
        '.coluna-esquerda',
        '#j_id_jsp_1880941391_47', // Rodapé
        '.Rodape',
        '#espacoVazioRodape',
        'div[layout="block"]', // Banners
        '#divAvisoNavegador',
        '#conteinerAjuda',
        '#containerAcessibilidade'
      ];

      toRemove.forEach(sel => {
        try {
          const els = document.querySelectorAll(sel);
          els.forEach(e => e.style.display = 'none');
        } catch(e){}
      });

      // Ajusta o container de login para tela cheia/centralizado
      const loginContainer = document.querySelector('.login.ui-corner-all');
      if (loginContainer) {
        loginContainer.style.position = 'absolute';
        loginContainer.style.top = '50%';
        loginContainer.style.left = '50%';
        loginContainer.style.transform = 'translate(-50%, -50%)';
        loginContainer.style.width = '90%';
        loginContainer.style.maxWidth = '400px';
        loginContainer.style.margin = '0';
        loginContainer.style.float = 'none';
        loginContainer.style.backgroundColor = '#fff';
        loginContainer.style.zIndex = '9999';
        
        // Garante que os inputs e o captcha estejam visíveis
        const inputs = loginContainer.querySelectorAll('input');
        inputs.forEach(i => {
            i.style.width = '100%';
            i.style.marginBottom = '10px';
            i.style.padding = '10px';
        });
        
        const captcha = document.getElementById('widget-captcha');
        if(captcha) {
            captcha.style.transform = 'scale(0.85)'; // Reduz um pouco para caber em telas pequenas
            captcha.style.transformOrigin = '0 0';
            captcha.style.marginBottom = '20px';
        }
      }
      
      // Ajusta o fundo
      document.body.style.backgroundColor = '#f0f2f5';
      const conteudoDiv = document.querySelector('.Conteudo');
      if(conteudoDiv) {
        conteudoDiv.style.width = '100%';
        conteudoDiv.style.background = 'transparent';
      }
  })();
  """;

  static String extractGradesScript() => """
(function() {
  try {
    const iframe = document.getElementById('Conteudo');
    if (!iframe) {
        return JSON.stringify([{ "error": "iFrame 'Conteudo' não encontrado." }]);
    }
    const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
    if (!iframeDoc) {
        return JSON.stringify([{ "error": "Não foi possível acessar o conteúdo do iFrame." }]);
    }

    const mainContainer = iframeDoc.getElementById('form-corpo');
    if (!mainContainer) {
        return JSON.stringify([{ "error": "Container 'form-corpo' não encontrado no iFrame." }]);
    }

    const disciplinas = [];
    
    for (const element of mainContainer.children) {
        if (element.tagName === 'DIV' && /^\\d{4}\\.\\d\$/.test(element.id)) {
            const periodDiv = element;
            const periodName = periodDiv.id;

            const subjectTables = periodDiv.querySelectorAll('table[id="tagrodape"]');
            for (const headerTable of subjectTables) {
                try {
                    const nameElement = headerTable.querySelector('font.editPesquisa');
                    
                    let parentTable = headerTable.parentElement;
                    while (parentTable && parentTable.tagName !== 'TABLE') {
                        parentTable = parentTable.parentElement;
                    }
                    
                    const detailsDiv = parentTable ? parentTable.nextElementSibling : null;

                    if (!nameElement || !detailsDiv || detailsDiv.tagName !== 'DIV') continue;

                    const nome = nameElement.innerText.trim().replace(/\\s+/g, ' ');

                    const statusElement = detailsDiv.querySelector('font.editPesquisa > u');
                    const situacao = statusElement ? statusElement.innerText.trim() : 'Cursando';

                    // Extrair nome do professor
                    let teacher = '';
                    const teacherTables = detailsDiv.querySelectorAll('table');
                    for (const table of teacherTables) {
                        const rows = table.querySelectorAll('tr');
                        for (const row of rows) {
                            const cells = row.querySelectorAll('td');
                            if (cells.length >= 2) {
                                const labelCell = cells[0].querySelector('font.edit b');
                                if (labelCell && labelCell.innerText.includes('Docente')) {
                                    const teacherCell = cells[1].querySelector('font.editPesquisa');
                                    if (teacherCell) {
                                        teacher = teacherCell.innerText.trim();
                                        break;
                                    }
                                }
                            }
                        }
                        if (teacher) break;
                    }

                    const notas = {};
                    const headerCells = detailsDiv.querySelectorAll('td[bgcolor="#FAEBD7"]');
                    if (headerCells.length > 0) {
                        const headerRow = headerCells[0].parentElement;
                        const valueRow = headerRow.nextElementSibling;
                        if (valueRow) {
                            const headers = Array.from(headerRow.children).map(cell => cell.innerText.trim());
                            const values = Array.from(valueRow.children).map(cell => cell.innerText.trim());
                            for (let i = 1; i < headers.length; i++) {
                                if (headers[i] && values[i] && values[i] !== '-') {
                                    notas[headers[i]] = values[i];
                                }
                            }
                        }
                    }
                    
                    disciplinas.push({
                        nome: nome,
                        semestre: periodName,
                        situacao: situacao,
                        notas: notas,
                        teacher: teacher
                    });

            } catch (e) {
                console.error('Erro ao analisar uma disciplina no período ' + periodName + ': ' + e);
            }
        }
    }
}
return JSON.stringify(disciplinas);
} catch (e) {
  return JSON.stringify([{ "error": e.toString() }]);
}
})();
""";

  static String scriptNav() =>
      r"""new Promise((resolve,reject)=>{const maxTries=3000;let tries=0;const interval=setInterval(()=>{tries++;const anchors=Array.from(document.querySelectorAll('a'));const el=anchors.find(a=>(a.textContent||'').trim()==='Detalhamento de Discente');if(el){clearInterval(interval);try{el.click();resolve('SUCESSO');}catch(e){try{const evt=new MouseEvent('click',{bubbles:true,cancelable:true,view:window});el.dispatchEvent(evt);resolve('SUCESSO');}catch(err){reject('ERRO:'+err);}}return;}if(tries>=maxTries){clearInterval(interval);reject('ERRO: Menu não encontrado');}},20);});""";

  static String scriptInfo() =>
      r"""new Promise((resolve,reject)=>{const maxTries=3000;let tries=0;const interval=setInterval(()=>{const iframe=document.getElementById('Conteudo');if(iframe&&iframe.contentDocument){const infoLink=iframe.contentDocument.getElementById('form:repeatTransacoes:2:outputLinkTransacao');if(infoLink){clearInterval(interval);infoLink.click();resolve('SUCESSO');return;}}tries++;if(tries>=maxTries){clearInterval(interval);reject('ERRO: Link Informacoes não encontrado');}},20);});""";

  static String scriptPerfil() =>
      r"""new Promise((resolve,reject)=>{const iframe=document.getElementById('Conteudo');if(iframe&&iframe.contentDocument){const sanfonaLinks=iframe.contentDocument.querySelectorAll('ul.sanfona a');for(let i=0;i<sanfonaLinks.length;i++){if(sanfonaLinks[i].innerText.trim()==='Perfil Curricular'){sanfonaLinks[i].click();resolve('SUCESSO');return;}}}reject('ERRO: Perfil Curricular nao encontrado');});""";

  static String getHtmlScript() =>
      r"""(function(){try{const mainIframe=document.getElementById('Conteudo');if(!mainIframe||!mainIframe.contentDocument)return JSON.stringify({ "error": "Iframe principal não encontrado." });const contentDiv=mainIframe.contentDocument.getElementById('content');if(!contentDiv)return JSON.stringify({ "error": "Div de conteúdo do perfil não encontrado." });return contentDiv.innerHTML;}catch(e){return JSON.stringify({ "error": "Exceção ao acessar o conteúdo do iframe: "+e.toString() });}})();""";

  static String waitForProfilePageReadyScript() =>
      r"""(function(){const mainIframe=document.getElementById('Conteudo');if(!mainIframe||!mainIframe.contentDocument){return 'error_main_iframe';}const profileForm=mainIframe.contentDocument.getElementById('formDetalharPerfilCurricular');return profileForm!=null;})();""";

  static String scriptGradeHorario() =>
      r"""new Promise((resolve,reject)=>{const iframe=document.getElementById('Conteudo');if(iframe&&iframe.contentDocument){const sanfonaLinks=iframe.contentDocument.querySelectorAll('ul.sanfona a');for(let i=0;i<sanfonaLinks.length;i++){if(sanfonaLinks[i].innerText.trim()==='Grade de Horário'){sanfonaLinks[i].click();resolve('SUCESSO');return;}}}reject('ERRO: Link Grade de Horário não encontrado');});""";

  static String waitForTimetablePageReadyScript() =>
      r"""(function(){const mainIframe=document.getElementById('Conteudo');if(!mainIframe||!mainIframe.contentDocument){return 'error_main_iframe';}const title=mainIframe.contentDocument.querySelector('font.subtitle');return title!=null && title.innerText.includes('Disciplinas Solicitadas');})();""";

  static String extractTimetableScript() => r"""
(function() {
    try {
        const iframe = document.getElementById('Conteudo');
        if (!iframe || !iframe.contentDocument) {
            return JSON.stringify([{ "error": "iFrame 'Conteudo' não encontrado." }]);
        }
        const doc = iframe.contentDocument;

        // 1. Extrair detalhes da lista de disciplinas
        const subjectsMap = new Map();
        const subjectRows = doc.querySelectorAll('table[width="600"] tr');
        
        for (const row of subjectRows) {
            const cells = row.querySelectorAll('td font.editPesquisa');
            
            // Se a linha não tiver 6 colunas, ela não é uma disciplina válida.
            // Isso ignora linhas de aviso como "não há vagas".
            if (cells.length < 6) {
                continue; // Pula para a próxima iteração do loop
            }

            const code = cells[0].innerText.trim();
            // Ignora linhas de cabeçalho ou inválidas que possam ter 6 colunas
            if (!code || code === 'CÓDIGO') {
                continue;
            }

            subjectsMap.set(code, {
                code: code,
                name: cells[1].innerText.trim(),
                className: cells[2].innerText.trim(),
                room: cells[4].innerText.trim(),
                status: cells[5].innerText.trim(),
                timeSlots: []
            });
        }
        
        // 2. Extrair horários da tabela de grade
        const timetableRows = doc.querySelectorAll('table[width="570"] tr');
        const days = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB'];

        for (const row of timetableRows) {
            const cells = row.querySelectorAll('td.textoTabela');
            if (cells.length === 6) { // 6 dias da semana
                for (let i = 0; i < cells.length; i++) {
                    const cell = cells[i];
                    const cellHtml = cell.innerHTML;
                    if (cellHtml.includes('<br>')) {
                        const parts = cellHtml.split('<br>');
                        const codeMatch = parts[0].match(/([A-Z0-9]+)\s*-\s*([A-Z0-9]+)/);
                        const timeMatch = parts[1].match(/(\d{2}:\d{2})\s*às\s*(\d{2}:\d{2})/);

                        if (codeMatch && timeMatch) {
                            const subjectCode = codeMatch[1];
                            const subject = subjectsMap.get(subjectCode);
                            if (subject) {
                                subject.timeSlots.push({
                                    day: days[i],
                                    startTime: timeMatch[1],
                                    endTime: timeMatch[2]
                                });
                            }
                        }
                    }
                }
            }
        }
        
        return JSON.stringify(Array.from(subjectsMap.values()));

    } catch (e) {
        return JSON.stringify([{ "error": e.toString() }]);
    }
})();
""";

  static String extractUserScript() => r"""
(function() {
    try {
        const iframe = document.getElementById('Conteudo');
        if (!iframe || !iframe.contentDocument) {
            return JSON.stringify({ "error": "iFrame 'Conteudo' não encontrado." });
        }
        const doc = iframe.contentDocument;

        const data = {};
        const rows = doc.querySelectorAll('#tableCabecalho tr');

        const fieldMapping = {
            'CPF:': 'cpf',
            'Matrícula:': 'registration',
            'Nome:': 'name',
            'Curso:': 'course',
            'Período de Ingresso:': 'entryPeriod',
            'Tipo do Ingresso:': 'entryType',
            'Perfil:': 'profile',
            'Turno:': 'shift',
            'Situação:': 'situation',
            'Período Letivo Corrente:': 'currentPeriod'
        };

        rows.forEach(row => {
            const labelEl = row.querySelector('font.edit');
            const valueEl = row.querySelector('font.editPesquisa');
            if (labelEl && valueEl) {
                const label = labelEl.innerText.trim();
                const key = fieldMapping[label];
                if (key) {
                    data[key] = valueEl.innerText.trim().replace(/\s+/g, ' ');
                }
            }
        });

        return JSON.stringify(data);
    } catch (e) {
        return JSON.stringify({ "error": e.toString() });
    }
})();
""";

  static String scriptHistoricoEscolar() =>
      r"""new Promise((resolve,reject)=>{const iframe=document.getElementById('Conteudo');if(iframe&&iframe.contentDocument){const links=iframe.contentDocument.querySelectorAll('a.default');for(const link of links){if(link.innerText.trim()==='Histórico Escolar'){link.click();resolve('SUCCESS');return;}}}reject('ERROR: Link "Histórico Escolar" not found');});""";

  static String waitForSchoolHistoryPageReadyScript() =>
      r"""(function(){const iframe=document.getElementById('Conteudo');if(!iframe||!iframe.contentDocument)return false; const tables = iframe.contentDocument.querySelectorAll('table'); for(const table of tables) { if(table.innerText.includes('Componente Curricular')) { return true; } } return false; })();""";

  static String extractSchoolHistoryScript() => r'''
function parseSchoolHistory() {
  try {
    let iframeDoc;
    const iframe = document.getElementById('Conteudo');
    
    // Tenta obter o documento a partir do iframe.
    if (iframe && iframe.contentDocument) {
      iframeDoc = iframe.contentDocument;
    } else {
      // Se não encontrar, assume que já está no contexto do documento correto.
      iframeDoc = document;
    }

    // O resto do script continua a partir daqui, usando 'iframeDoc'.
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

    const allPeriods = [];
    const mainContainer = iframeDoc.querySelector('div#content');
    if (!mainContainer) {
        return JSON.stringify({ error: "Container principal '#content' não foi encontrado." });
    }

    const periodMarkers = Array.from(mainContainer.querySelectorAll('table')).filter(table =>
      table.innerText.trim().startsWith('Período:')
    );

    for (const marker of periodMarkers) {
      const periodName = marker.querySelector('.editPesquisa.fonte8pt')?.innerText.trim();
      if (!periodName) continue;

      const periodObject = {
        period: periodName,
        subjects: [],
        periodAverage: null,
        periodCoefficient: null,
      };

      let contentTable = marker.nextElementSibling;
      while (contentTable && contentTable.tagName !== 'TABLE') {
        contentTable = contentTable.nextElementSibling;
      }

      if (!contentTable) continue;

      const rows = Array.from(contentTable.querySelectorAll('tr'));
      
      if (rows.length === 1 && rows[0].cells.length === 1) {
          const specialStatusText = rows[0].innerText.trim();
          periodObject.subjects.push({
              code: 'N/A', name: specialStatusText, absences: 0,
              workload: 0, credits: 0, finalGrade: null, status: specialStatusText,
          });
      } else {
          for (const row of rows) {
            const cells = row.cells;
            if (cells.length === 6 && cells[0].querySelector('.editPesquisa.fonte8pt')) {
              const { code, name } = splitCodeAndName(cells[0].innerText);
              periodObject.subjects.push({
                code: code, name: name,
                absences: parseValue(cells[1].innerText),
                workload: parseValue(cells[2].innerText),
                credits: parseValue(cells[3].innerText),
                finalGrade: parseValue(cells[4].innerText),
                status: parseValue(cells[5].innerText),
              });
            } else if (row.innerText.includes('Média do Período:')) {
              periodObject.periodAverage = parseValue(cells[cells.length - 1].innerText);
            } else if (row.innerText.includes('Coeficiente de Rendimento Escolar no Período:')) {
              periodObject.periodCoefficient = parseValue(cells[cells.length - 1].innerText);
            }
          }
      }
      allPeriods.push(periodObject);
    }

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
            } else if (row.innerText.includes('Coeficiente de Rendimento Escolar Geral:')) {
                overallCoefficient = parseValue(row.cells[row.cells.length - 1].innerText);
            }
        });
    }

    return JSON.stringify({
      periods: allPeriods,
      overallAverage: overallAverage,
      overallCoefficient: overallCoefficient,
    });
  } catch (e) {
    return JSON.stringify({ error: "Erro ao executar script de extração: " + e.toString() });
  }
}

// Executa a função
parseSchoolHistory();
''';

  static String scriptAproveitamentoAcademico() =>
      r"""new Promise((resolve,reject)=>{const iframe=document.getElementById('Conteudo');if(iframe&&iframe.contentDocument){const links=iframe.contentDocument.querySelectorAll('a.default');for(const link of links){if(link.innerText.trim()==='Aproveitamento Acadêmico'){link.click();resolve('SUCCESS');return;}}}reject('ERROR: Link "Aproveitamento Acadêmico" not found');});""";

  static String waitForAcademicAchievementPageReadyScript() =>
      r"""(function(){const iframe=document.getElementById('Conteudo');if(!iframe||!iframe.contentDocument)return false; const button = iframe.contentDocument.getElementById('bt_a1'); return button != null; })();""";
  static String extractAcademicAchievementScript() => r'''
function extractAcademicAchievement() {
  try {
    const iframe = document.getElementById('Conteudo');
    if (!iframe || !iframe.contentDocument) {
      return JSON.stringify({ error: "Iframe 'Conteudo' não encontrado." });
    }
    const doc = iframe.contentDocument;

    // --- Funções Auxiliares ---
    const parseNumber = (text) => {
      if (!text || text.trim() === '-') return null;
      const cleaned = text.trim().replace(/\./g, '').replace(',', '.');
      const num = parseFloat(cleaned);
      return isNaN(num) ? null : num;
    };

    const parsePercentage = (text) => {
        if (!text || text.trim() === '-') return null;
        const cleaned = text.trim().replace('%', '').replace(',', '.');
        const num = parseFloat(cleaned);
        return isNaN(num) ? null : num;
    };

    // --- 1. Resumo Carga Horária ---
    const workloadSummaryList = [];
    const workloadButton = doc.querySelector('input#bt_a1');
    if (workloadButton) {
        const workloadTable = workloadButton.nextElementSibling.nextElementSibling;
        if (workloadTable && workloadTable.tagName === 'TABLE') {
            const rows = workloadTable.querySelectorAll('tr[id^="a1."]');
            rows.forEach(row => {
                const cells = row.querySelectorAll('td');
                const rowId = row.getAttribute('id');

                // Ignora linha de cabeçalho E A LINHA "ATENÇÃO:" (a1.13)
                if(cells.length < 2 || cells[0].querySelector('.tituloColuna') || rowId === 'a1.13') return;

                let nameElement = cells[0].querySelector('font.edit');
                let name = nameElement ? nameElement.innerText.trim() : cells[0].innerText.trim();
                name = name.replace(/[-]/g, '').replace(/\u00A0/g, ' ').trim();

                const buttonElement = cells[0].querySelector('input.botao2, input.botao_desativado');
                if (buttonElement) {
                    name = name.replace(buttonElement.outerHTML, '').trim();
                     // Tratamento especial para remover texto residual de botões em casos específicos
                     if (buttonElement.nextSibling && buttonElement.nextSibling.nodeType === Node.TEXT_NODE) {
                         name = buttonElement.nextSibling.textContent.trim();
                     } else if (nameElement && nameElement.childNodes.length > 1) {
                         // Tenta pegar o último nó de texto dentro do <font>
                          const lastNode = nameElement.childNodes[nameElement.childNodes.length - 1];
                          if (lastNode.nodeType === Node.TEXT_NODE) {
                              name = lastNode.textContent.trim();
                          }
                     }
                      name = name.replace(/[-]/g, '').replace(/\u00A0/g, ' ').trim(); // Limpa novamente
                }


                let parentId = null;
                const idParts = rowId.split('.');
                if (idParts.length > 2) {
                    parentId = idParts.slice(0, -1).join('.');
                }

                 if (cells.length >= 8) {
                    workloadSummaryList.push({
                        id: rowId, parentId: parentId, name: name,
                        integration: parseNumber(cells[1].innerText),
                        completed_hours: parseNumber(cells[2].innerText),
                        completed_percentage: parsePercentage(cells[3].innerText),
                        waived_hours: parseNumber(cells[4].innerText),
                        waived_percentage: parsePercentage(cells[5].innerText),
                        to_complete_hours: parseNumber(cells[6].innerText),
                        to_complete_percentage: parsePercentage(cells[7].innerText),
                    });
                 } else if (cells.length > 1) {
                     workloadSummaryList.push({
                        id: rowId, parentId: parentId, name: name,
                        integration: parseNumber(cells[1].innerText),
                        completed_hours: cells.length > 2 ? parseNumber(cells[2].innerText) : null,
                        completed_percentage: cells.length > 3 ? parsePercentage(cells[3].innerText) : null,
                        waived_hours: cells.length > 4 ? parseNumber(cells[4].innerText) : null,
                        waived_percentage: cells.length > 5 ? parsePercentage(cells[5].innerText) : null,
                        to_complete_hours: cells.length > 6 ? parseNumber(cells[6].innerText) : null,
                        to_complete_percentage: cells.length > 7 ? parsePercentage(cells[7].innerText) : null,
                     });
                 }
            });
        }
    }


    // --- 2. Resumo de Realização ---
    const componentSummary = [];
    const componentTable = doc.querySelector('table[id="a2.2.1"]');
    if (componentTable) {
      const rows = componentTable.querySelectorAll('tr');
      rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length < 2 || cells[0].querySelector('.tituloColuna')) return;

        const description = cells[0].innerText.trim();
        const hours = parseNumber(cells[1].innerText);
        const quantity = cells.length > 2 ? parseNumber(cells[2].innerText) : null;

        if (description === 'Total de componentes aproveitados') {
             componentSummary.push({ description: description, hours: null, quantity: parseNumber(cells[1].innerText) });
        } else if (description === 'Utilizados como Equivalência**') {
             componentSummary.push({ description: description, hours: null, quantity: parseNumber(cells[2].innerText) });
        } else if (description) {
             componentSummary.push({ description: description, hours: hours, quantity: quantity });
        }
      });
    }

    // --- 3. Componentes Pendentes ---
    const pendingComponents = { subjects: [], total_pending_hours: null }; // Inicializa como null
    const pendingTable = doc.querySelector('table[id="a3.1"]');
    if (pendingTable) {
      const rows = pendingTable.querySelectorAll('tr');
      rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        if (cells.length === 4 && cells[0].querySelector('font.editPesquisa')) {
             const nameWithCodeRaw = cells[0].querySelector('font.editPesquisa').innerText.trim();
             const nameWithCode = nameWithCodeRaw.substring(nameWithCodeRaw.indexOf('.') + 1).trim();
             const codeMatch = nameWithCode.match(/^([A-Z0-9]+)\s*-\s*(.*)$/);
             pendingComponents.subjects.push({
                 code: codeMatch ? codeMatch[1] : null,
                 name: codeMatch ? codeMatch[2] : nameWithCode,
                 workload: parseNumber(cells[1].innerText),
                 period: parseNumber(cells[2].innerText),
                 credits: parseNumber(cells[3].innerText),
             });
         // --- CORREÇÃO para Total Horas Pendentes ---
        } else if (row.innerText.includes('TOTAL PENDENTE')) {
            const cells = row.querySelectorAll('td');
            if (cells.length > 0) {
                const lastCell = cells[cells.length - 1];
                // Tenta buscar dentro de <font><b>...</b></font> ou só <b>...</b>
                const boldTextElement = lastCell.querySelector('font.editPesquisa > b') ?? lastCell.querySelector('b');
                const text = boldTextElement?.innerText || ''; // Ex: "TOTAL PENDENTE = 1050 horas"
                const match = text.match(/=\s*(\d+)/); // Procura por "= numero"
                if (match && match[1]) {
                    pendingComponents.total_pending_hours = parseInt(match[1], 10);
                } else {
                     console.error("Could not parse total pending hours from:", text);
                     pendingComponents.total_pending_hours = 0; // Define 0 se não encontrar
                }
            }
        }
        // --- FIM CORREÇÃO ---
      });
       // Se após percorrer a tabela, o total ainda for null (não encontrou a linha), define como 0
      if(pendingComponents.total_pending_hours === null) {
          pendingComponents.total_pending_hours = 0;
      }
    } else {
        // Se a tabela não for encontrada, define como 0
        pendingComponents.total_pending_hours = 0;
    }

    return JSON.stringify({
      workload_summary: JSON.stringify(workloadSummaryList), // Stringify a lista aqui
      component_summary: JSON.stringify(componentSummary), // Stringify a lista aqui
      pending_components: { // Mantém o objeto, mas stringify 'subjects'
          subjects: JSON.stringify(pendingComponents.subjects),
          total_pending_hours: pendingComponents.total_pending_hours
      },
    });
  } catch (e) {
    return JSON.stringify({ error: `An exception occurred: ${e.toString()}` });
  }
}

extractAcademicAchievement();
''';
}
