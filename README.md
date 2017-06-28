# Configuração do Ubuntu 16.04 LTS para computadores multiterminais do ProInfo

**URGENTE: seu multiterminal parou de funcionar após uma atualização de sistema? Leia [isto](../../wikis/problemas-com-atualizacoes-de-sistema)!**

*Aqui você encontra apenas algumas informações resumidas sobre este roteiro. A documentação completa está disponível em nosso [wiki](../../wikis/home).*

## Pregões contemplados por esta solução

### ProInfo Urbano

* 83/2008
* 72/2010

### ProInfo Rural

* 68/2009 (2º lote)

### Observações

* Esta solução não se aplica aos computadores do pregão 23/2012, devido à falta de um driver de vídeo compatível com as placas TN-750.
* Esta solução pode aplicar-se a outros pregões do ProInfo Rural, **desde que a placa de vídeo original ATI Rage XL Quad seja substituída por um par de placas TN-502 Dual ou uma placa TN-502 Quad**.

## Sabores do Ubuntu recomendados para os computadores do ProInfo

Os sabores e arquiteturas do Ubuntu que nós recomendamos para os computadores do ProInfo são os seguintes:

| Tipo de computador                            | Sabor do Ubuntu                                                                                                                                                                                             | Arquitetura |
|:---------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-----------:|
| multiterminal com menos de 2GB de memória RAM (4GB para até 5 terminais) | [Xubuntu](http://cdimage.ubuntu.com/xubuntu/releases/xenial/release/xubuntu-16.04-desktop-i386.iso) ou [Lubuntu](http://cdimage.ubuntu.com/lubuntu/releases/16.04/release/lubuntu-16.04-desktop-i386.iso)   | 32 bits     |
| multiterminal com 2GB de memória RAM (para até 3 terminais) ou mais  | [Xubuntu](http://cdimage.ubuntu.com/xubuntu/releases/xenial/release/xubuntu-16.04-desktop-amd64.iso) ou [Lubuntu](http://cdimage.ubuntu.com/lubuntu/releases/16.04/release/lubuntu-16.04-desktop-amd64.iso) | 64 bits     |
| servidor                                      | [Xubuntu](http://cdimage.ubuntu.com/xubuntu/releases/xenial/release/xubuntu-16.04-desktop-amd64.iso) ou [Ubuntu MATE](http://cdimage.ubuntu.com/ubuntu-mate/releases/xenial/release/ubuntu-mate-16.04-desktop-amd64.iso)                                                                                            | 64 bits     |

## Resumo do roteiro

1. Instale o seu sabor preferido do Ubuntu 16.04 LTS.
2. Identifique as portas USB traseiras de cada um dos seus computadores seguindo [este roteiro](../../wikis/Identificando-as-portas-USB-traseiras), reservando as portas USB 1 e 2 para o segundo e terceiro terminais, respectivamente.
  * Nos computadores do ProInfo Rural, as portas USB 3 e 4 são reservadas para o quarto e quinto terminais, respectivamente. Nos do ProInfo Urbano, por sua vez, estas podem ser livremente utilizadas no primeiro terminal.
  * Em todos os casos, as portas USB frontais podem ser usadas livremente no primeiro terminal.
3. Conecte os monitores e hubs USB associados a cada terminal, segundo [esta tabela](../../wikis/Tabela-de-associacao-das-portas-USB-e-saidas-de-video).
4. Baixe este repositório (`git clone http://gitlab.sme-mogidascruzes.sp.gov.br/pte/proinfo-ubuntu-config.git`).
5. Execute o script `criar-usuarios-alunos.sh`.
6. **[OPCIONAL]** Execute o script `reconfigurar-rede.sh`.
7. Execute o script `configurar-multiterminal.sh`.

Caso algum de seus computadores seja afetado pelo [bug da tela listrada](../../wikis/O-bug-da-tela-listrada), os seguintes passos adicionais são necessários para utilizá-lo em sua capacidade máxima (3 terminais no ProInfo Urbano e 4~5 terminais no ProInfo Rural):

1. Baixe a ISO para recuperação do vídeo, disponível no nosso [Google Drive](https://drive.google.com/open?id=0B_0RrXAKZ1hbdnRvcGRuSFc2Nkk).
2. Mova a ISO baixada para a pasta `/boot/userful-rescue`.
3. Execute o script `contornar-bug-tela-listrada.sh` que consta desta solução.
4. Desligue e ligue novamente o computador.