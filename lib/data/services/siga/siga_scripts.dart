import 'dart:core';

class SigaScripts {
  /// Retorna script para login. Passar valores já escapados.
  static String loginScript(String user, String pass) {
    return "(function(){try{var u=document.getElementById('cpf')||document.getElementsByName('cpf')[0]||null;var p=document.getElementById('txtPassword')||document.getElementsByName('txtPassword')[0]||null;if(u)u.value='$user';if(p)p.value='$pass';var btn=document.getElementById('btnEntrar');if(btn){btn.click();return;}var form=document.getElementById('formulario')||document.forms[0];if(form)form.submit();}catch(e){} })();";
  }

  static String scriptGoHome() =>
      "document.getElementById('menuTopo:imageHome').click();";

  static String checkLoginScript() =>
      "document.getElementById('lblNomePessoa') != null;";

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
      r"""new Promise((resolve,reject)=>{const maxTries=40;let tries=0;const interval=setInterval(()=>{const iframe=document.getElementById('Conteudo');if(iframe&&iframe.contentDocument){const infoLink=iframe.contentDocument.getElementById('form:repeatTransacoes:2:outputLinkTransacao');if(infoLink){clearInterval(interval);infoLink.click();resolve('SUCESSO');return;}}tries++;if(tries>=maxTries){clearInterval(interval);reject('ERRO: Link Informacoes não encontrado');}},250);});""";

  static String scriptPerfil() =>
      r"""new Promise((resolve,reject)=>{const iframe=document.getElementById('Conteudo');if(iframe&&iframe.contentDocument){const sanfonaLinks=iframe.contentDocument.querySelectorAll('ul.sanfona a');for(let i=0;i<sanfonaLinks.length;i++){if(sanfonaLinks[i].innerText.trim()==='Perfil Curricular'){sanfonaLinks[i].click();resolve('SUCESSO');return;}}}reject('ERRO: Perfil Curricular nao encontrado');});""";

  static String getHtmlScript() =>
      r"""(function(){try{const mainIframe=document.getElementById('Conteudo');if(!mainIframe||!mainIframe.contentDocument)return JSON.stringify({ "error": "Iframe principal não encontrado." });const contentDiv=mainIframe.contentDocument.getElementById('content');if(!contentDiv)return JSON.stringify({ "error": "Div de conteúdo do perfil não encontrado." });return contentDiv.innerHTML;}catch(e){return JSON.stringify({ "error": "Exceção ao acessar o conteúdo do iframe: "+e.toString() });}})();""";

  static String waitForProfilePageReadyScript() =>
      r"""(function(){const mainIframe=document.getElementById('Conteudo');if(!mainIframe||!mainIframe.contentDocument){return 'error_main_iframe';}const profileForm=mainIframe.contentDocument.getElementById('formDetalharPerfilCurricular');return profileForm!=null;})();""";
}
