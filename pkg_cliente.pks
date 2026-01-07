CREATE OR REPLACE PACKAGE PKG_CLIENTE AS

   -- variáveis globais
   ve_erro     exception;
   vv_string   varchar2(32767);
   vv_msg_erro varchar2(32767);
   vn_cd_erro  number(5);
   vt_uf       dbms_sql.varchar2_table;

   type t_rec_cliente is record ( id_cliente     tb_cliente.id_cliente%type
                                , nome           tb_cliente.nome%type
                                , email          tb_cliente.email%type
                                , cep            tb_cliente.cep%type
                                , logradouro     tb_cliente.logradouro%type
                                , numero         tb_cliente.numero%type
                                , bairro         tb_cliente.bairro%type
                                , cidade         tb_cliente.cidade%type
                                , uf             tb_cliente.uf%type
                                , ativo          tb_cliente.ativo%type
                                , dt_criacao     tb_cliente.dt_criacao%type
                                , dt_atualizacao tb_cliente.dt_atualizacao%type            
                                );
                                   
   type t_tab_rec_cliente is table of t_rec_cliente index by binary_integer;

   FUNCTION FN_EMAIL_VALIDO ( ev_email in varchar2 ) RETURN NUMBER;

   FUNCTION FN_CEP_VALIDO ( ev_cep in varchar2 ) RETURN NUMBER;

   PROCEDURE PRC_LISTAR_CLIENTE  ( ev_nome          in            tb_cliente.nome%type
                                 , ev_email         in            tb_cliente.email%type
                                 , est_cliente      in out nocopy t_tab_rec_cliente 
                                 );

   PROCEDURE PRC_INSERIR_CLIENTE ( est_cliente      in out nocopy t_tab_rec_cliente 
                                 );

   PROCEDURE PRC_ALTERAR_CLIENTE ( est_cliente      in out nocopy t_tab_rec_cliente 
                                 );

   PROCEDURE PRC_DELETAR_CLIENTE ( est_cliente      in out nocopy t_tab_rec_cliente 
                                 );

   PROCEDURE PRC_LOCK_REG_CLIENTE( est_cliente      in out nocopy t_tab_rec_cliente 
                                 ); 
   
   PROCEDURE PRC_LOV_UF ( st_lov out nocopy dbms_sql.varchar2_table );
   
   PROCEDURE PRC_VALIDA ( ev_bloco in varchar2
                        , ev_campo in varchar2
                        , ev_valor in varchar2
                        );
                                 
END PKG_CLIENTE;
/