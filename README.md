>  **ATENÇÃO: Recomendamos fortemente a visualização completa das instruções detalhadas no** [Manual do Usuário do LE6](https://linuxeducacional.c3sl.ufpr.br/instalacao/).

### 1.  **Requisitos do Multiterminal**

Para executar o sistema multiterminal em seu computador, você precisa ter a placa de vídeo **TN-502** e o **HUB ThinNetworks** (encontrados nos pregões **83/2008** e **72/2010**).

O multiterminal suporta um máximo de 3 (três) monitores simultâneos: 1 (um) conectado à placa de vídeo *Onboard* e 2 (dois) conectados à placa TN-502. É necessário 1 (um) HUB para cada saída de vídeo **adicional** utilizada, ou seja, 1 (um) HUB a menos que a quantidade total de monitores desejada.

A tabela a seguir explicita a quantidade de HUBs necessária para até 3 (três) monitores. É importante seguir essa configuração, pois o número de HUBs é o que determina a quantidade de monitores adicionais que o sistema multiterminal espera configurar.

| Quantidade de monitores | Quantidade de HUBs |
|:-----------------------:|:------------------:|
| 1 (um) | Nenhum |
| 2 (dois) | 1 (um) |
| 3 (três) | 2 (dois) |

A solução atual não possui compatibilidade com os computadores do pregão 23/2012, devido à falta de um *driver* de vídeo necessário para as placas TN-750. Entretanto, substituir a placa TN-750 por uma TN-502 permite que o sistema multiterminal funcione no pregão 23/2012.


### 2. **Disposição dos dispositivos**

Primeiro, garanta que possui 1 (um) HUB ThinNetworks para cada monitor adicional desejado (conforme explicado na seção 1). A entrada de vídeo do monitor deve ser compatível com a placa de vídeo TN-502 (padrão **VGA**).

A disposição dos dispositivos segue uma regra simples, conforme o passo-a-passo:
1. Conecte os cabos VGA dos monitores que deseja utilizar nas saídas de vídeo do seu computador (placa *Onboard* e/ou TN-502).
2. Conecte um HUB para cada saída de vídeo adicional utilizada em qualquer porta USB do seu computador.
3. Para cada saída de vídeo, conecte o teclado, o *mouse* e (opcionalmente) a saída de áudio correspondentes em um **mesmo** HUB ThinNetworks. É importante que todos os dispositivos que você queira associar à mesma saída de vídeo estejam **no mesmo HUB**. Como você terá HUBs apenas para os monitores adicionais, faltará um HUB para um monitor. Conecte os dispositivos deste monitor diretamente no computador.

Uma vez que você possua todos os monitores conectados com seus respectivos HUBs e dispositivos seguindo o passo-a-passo acima, é possível iniciar a configuração do sistema multiteminal.



### 3. **Configuração do Multiterminal**


**Observação:** O [Manual do Usuário do LE6](https://linuxeducacional.c3sl.ufpr.br/instalacao/) possui imagens ilustrativas para auxiliar a compreensão desta seção.

Ao iniciar/reiniciar o computador pela primeira vez após a instalação do multiterminal, todos os monitores conectados ao computador devem exibir instruções de configuração. Se a mensagem exibida é "Aguarde", o sistema multiterminal está carregando os componentes necessários para prosseguir e logo deve iniciar. Não pressione nenhuma tecla até ser solicitado.

A primeira instrução é "Pressiona a tecla Fx", sendo Fx uma das teclas F1..F3. Cada monitor conectado estará solicitando uma tecla diferente. Para cada monitor, pressione a tecla solicitada no teclado que você deseja associar à este monitor. É importante lembrar que o *mouse* e todos os dispositivos conectados no mesmo HUB (ou os dispositivos conectados diretamente no computador) serão associados ao monitor correspondente.

Assim que o teclado for corretamente associado ao monitor correspondente, a mensagem "Monitor configurado, aguardando os demais..." será exibida na tela do monitor configurado. Quando todos os monitores forem configurados, o computador será automaticamente reiniciado e as configurações aplicadas.

### 4. **Reiniciar a configuração do Multiterminal**

Se deseja alterar a configuração do sistema multiterminal, você precisa ter permissão de *root*. Abra um Terminal (aplicativo padrão do LE6) e digite o seguinte comando:

`sudo rm /etc/le-multiterminal/configurado`

A senha do seu usuário será solicitada e, após inserida, basta reiniciar o computador e seguir as instruções da seção 3.


### 5. **Colaboradores**

Temos o prazer de agradecer e reconhecer a colaboração:

*  Laércio de Sousa (<laerciosousa@sme-mogidascruzes.sp.gov.br>), por desenvolver e disponibilizar livremente uma solução do multiterminal na qual nos baseamos para desenvover a nossa solução.
