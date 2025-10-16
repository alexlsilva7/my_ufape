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
      r"""new Promise((resolve,reject)=>{const maxTries=1000;let tries=0;const interval=setInterval(()=>{tries++;const anchors=Array.from(document.querySelectorAll('a'));const el=anchors.find(a=>(a.textContent||'').trim()==='Detalhamento de Discente');if(el){clearInterval(interval);try{el.click();resolve('SUCESSO');}catch(e){try{const evt=new MouseEvent('click',{bubbles:true,cancelable:true,view:window});el.dispatchEvent(evt);resolve('SUCESSO');}catch(err){reject('ERRO:'+err);}}return;}if(tries>=maxTries){clearInterval(interval);reject('ERRO: Menu não encontrado');}},20);});""";

  static String scriptInfo() =>
      r"""new Promise((resolve,reject)=>{const maxTries=1000;let tries=0;const interval=setInterval(()=>{const iframe=document.getElementById('Conteudo');if(iframe&&iframe.contentDocument){const infoLink=iframe.contentDocument.getElementById('form:repeatTransacoes:2:outputLinkTransacao');if(infoLink){clearInterval(interval);infoLink.click();resolve('SUCESSO');return;}}tries++;if(tries>=maxTries){clearInterval(interval);reject('ERRO: Link Informacoes não encontrado');}},50);});""";

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
}
