CREATE OR REPLACE PACKAGE BODY PKG_CLIENTE AS
   
   /*
   ____________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   ____________________________________________________________________________________________
   Definicão........: Procedure para carregar vetor com as unidades federativas
   ____________________________________________________________________________________________
   */
   PROCEDURE PRC_CARREGA_UF IS   
   BEGIN
      
      vt_uf.delete;
      
      vt_uf(1)  := 'AC';
      vt_uf(2)  := 'AL';
      vt_uf(3)  := 'AP';
      vt_uf(4)  := 'AM';
      vt_uf(5)  := 'BA';
      vt_uf(6)  := 'CE';
      vt_uf(7)  := 'DF';
      vt_uf(8)  := 'ES';
      vt_uf(9)  := 'GO';
      vt_uf(10) := 'MA';
      vt_uf(11) := 'MT';
      vt_uf(12) := 'MS';
      vt_uf(13) := 'MG';
      vt_uf(14) := 'PA';
      vt_uf(15) := 'PB';
      vt_uf(16) := 'PR';
      vt_uf(17) := 'PE';
      vt_uf(18) := 'PI';
      vt_uf(19) := 'RJ';
      vt_uf(20) := 'RN';
      vt_uf(21) := 'RS';
      vt_uf(22) := 'RO';
      vt_uf(23) := 'RR';
      vt_uf(24) := 'SC';
      vt_uf(25) := 'SP';
      vt_uf(26) := 'SE';
      vt_uf(27) := 'TO';
      
   END PRC_CARREGA_UF;  
   
   /*
   ____________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   ____________________________________________________________________________________________
   Definicão........: Function para validar se o e-mail e valido
                      1 - valido
                      0 - invalido
   ____________________________________________________________________________________________
   */
   FUNCTION FN_EMAIL_VALIDO ( ev_email in varchar2 ) RETURN NUMBER IS   
      vn_ret number;
   BEGIN
      
      vn_ret := 0;
      
      select count(*)
        into vn_ret
        from dual
       where regexp_like (ev_email,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$');
      
      return nvl(vn_ret,0);
      
   END FN_EMAIL_VALIDO;
   
   /*
   ____________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   ____________________________________________________________________________________________
   Definicão........: Function para validar o cep
                      1 - valido
                      0 - invalido
   ____________________________________________________________________________________________
   */
   FUNCTION FN_CEP_VALIDO ( ev_cep in varchar2 ) RETURN NUMBER IS   
      vn_ret number;
   BEGIN
      
      vn_ret := 0;

      select count(*)
        into vn_ret
        from dual
       where regexp_like (lpad(ev_cep,8,0),'^[0-8]{1}.?[0-8]{3}-?[0-8]{3}$');
      
      return nvl(vn_ret,0);
      
   END FN_CEP_VALIDO;
   
    /*
   ____________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   ____________________________________________________________________________________________
   Definicão........: Procedimento criado para recuperar a sequence da tabela
   ____________________________________________________________________________________________
   */
   FUNCTION FN_SEQ_CLIENTE RETURN NUMBER IS   
   
   BEGIN
      return cliente_seq.nextval;      
   EXCEPTION
      when others then
         vv_msg_erro := 'Erro ao recuperar seq_cliente '||sqlerrm;
         raise_application_error(-20000,vv_msg_erro); 
   END FN_SEQ_CLIENTE;
   
   /*
   ____________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   ____________________________________________________________________________________________
   Definicão........: Procedimento criado para consultar as informacões da tabela tb_cliente
   ____________________________________________________________________________________________
   */
   PROCEDURE PRC_LISTAR_CLIENTE ( ev_nome          in            tb_cliente.nome%type
                                , ev_email         in            tb_cliente.email%type
                                , est_cliente      in out nocopy t_tab_rec_cliente
                                ) IS

   BEGIN
      
      vv_string := ' 
      select tb.id_cliente    
           , tb.nome          
           , tb.email         
           , tb.cep           
           , tb.logradouro    
           , tb.numero
           , tb.bairro        
           , tb.cidade        
           , tb.uf            
           , tb.ativo         
           , tb.dt_criacao    
           , tb.dt_atualizacao
        from tb_cliente tb ';

      if ev_nome is not null then
         vv_string := vv_string||'
         where tb.nome like :ev_nome';
      else
         vv_string := vv_string||'
         where ''ALL'' = :ev_nome ';
      end if;
      
      if ev_email is not null then
         vv_string := vv_string||'
         and tb.email  like ev_email ';
      else
         vv_string := vv_string||'
         and ''ALL'' = :ev_email ';
      end if; 
      
      begin
         execute immediate vv_string bulk collect into est_cliente using in nvl(ev_nome ,'ALL')
                                                                       , in nvl(ev_email,'ALL');
      exception
         when others then           
            vv_msg_erro := 'Erro ao executar consulta. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;           
            vn_cd_erro  := -20002;
            raise_application_error(vn_cd_erro,vv_msg_erro);           
      end;
      
      if est_cliente.count = 0 then
         vv_msg_erro := 'Registro nao encontrado!';           
         vn_cd_erro  := -20003;
         raise_application_error(vn_cd_erro,vv_msg_erro);
      end if;

   EXCEPTION
      when others then
         if vv_msg_erro is null then
            vv_msg_erro := 'Erro nao tratado pelo programa. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;
            vn_cd_erro  := -20000;
         end if;
         raise_application_error(vn_cd_erro,vv_msg_erro);   
         
   END PRC_LISTAR_CLIENTE;

   /*
   ____________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   ____________________________________________________________________________________________
   Definicão........: Procedimento criado para incluir informacões na tabela tb_cliente
   ____________________________________________________________________________________________
   */
   PROCEDURE PRC_INSERIR_CLIENTE ( est_cliente      in out nocopy t_tab_rec_cliente
                                 ) IS
      vn_aux number;
   BEGIN
      
      if est_cliente.count > 0 then

         for i in est_cliente.first .. est_cliente.last
         loop
            
            if est_cliente(i).id_cliente is null then
               est_cliente(i).id_cliente := pkg_cliente.fn_seq_cliente;
            end if;
            
            if est_cliente(i).nome is null then
               vv_msg_erro := 'Campo "NOME" nao pode ser nulo. Verifique!'; 
               vn_cd_erro  := -20001;
               raise_application_error(vn_cd_erro,vv_msg_erro);
            end if;            
            
            if est_cliente(i).email is null then
               vv_msg_erro := 'Campo "EMAIL" nao pode ser nulo. Verifique!'; 
               vn_cd_erro  := -20001;
               raise_application_error(vn_cd_erro,vv_msg_erro);
            end if;            
            
            if est_cliente(i).cep is null then
               vv_msg_erro := 'Campo "CEP" nao pode ser nulo. Verifique!'; 
               vn_cd_erro  := -20001;
               raise_application_error(vn_cd_erro,vv_msg_erro);
            end if;
             
            if est_cliente(i).uf is null then
               vv_msg_erro := 'Campo "UF" nao pode ser nulo. Verifique!'; 
               vn_cd_erro  := -20001;
               raise_application_error(vn_cd_erro,vv_msg_erro);
            end if;     
            
            vn_aux := 0;
            
            begin
               select count(*)
                 into vn_aux
                 from tb_cliente tb
                where tb.email      = est_cliente(i).email
                 and tb.id_cliente <> est_cliente(i).id_cliente;                
            exception
               when others then
                  vv_msg_erro := 'Erro ao validar e-mail. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM; 
                  vn_cd_erro  := -20000;
                  raise_application_error(vn_cd_erro,vv_msg_erro);
            end;
            
            if nvl(vn_aux,0) > 0 then
               vv_msg_erro := 'E-mail ja cadastrado para outro cliente. Verifique!'; 
               vn_cd_erro  := -20001;
               raise_application_error(vn_cd_erro,vv_msg_erro);
            end if;
            
            begin
               insert into tb_cliente    ( id_cliente    
                                         , nome          
                                         , email         
                                         , cep           
                                         , logradouro    
                                         , numero
                                         , bairro        
                                         , cidade        
                                         , uf            
                                         , ativo         
                                         , dt_criacao    
                                         , dt_atualizacao
                                         )
                                   values( est_cliente(i).id_cliente    
                                         , est_cliente(i).nome          
                                         , est_cliente(i).email         
                                         , est_cliente(i).cep           
                                         , est_cliente(i).logradouro    
                                         , est_cliente(i).numero    
                                         , est_cliente(i).bairro        
                                         , est_cliente(i).cidade        
                                         , est_cliente(i).uf            
                                         , est_cliente(i).ativo         
                                         , sysdate    
                                         , null
                                         );
            exception
               when others then
                  vv_msg_erro := 'Erro ao inserir cliente. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM; 
                  vn_cd_erro  := -20002;
                  raise_application_error(vn_cd_erro,vv_msg_erro);
            end;
               
         end loop;
      
      end if;
      
   EXCEPTION
      when others then
         if vv_msg_erro is null then
            vv_msg_erro := 'Erro nao tratado pelo programa. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;
            vn_cd_erro  := -20000;
         end if;
         
         raise_application_error(vn_cd_erro,vv_msg_erro);
         
   END PRC_INSERIR_CLIENTE;
   
   /*
   ____________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   ____________________________________________________________________________________________
   Definicão........: Procedimento criado para alterar as informacões da tabela tb_cliente
   ____________________________________________________________________________________________
   */
   PROCEDURE PRC_ALTERAR_CLIENTE ( est_cliente      in out nocopy t_tab_rec_cliente 
                                 ) IS

   BEGIN

      if est_cliente.count > 0 then

         for i in est_cliente.first .. est_cliente.last
         loop
            
            begin
               update tb_cliente tb
                  set tb.nome           = est_cliente(i).nome       
                    , tb.email          = est_cliente(i).email      
                    , tb.cep            = est_cliente(i).cep        
                    , tb.logradouro     = est_cliente(i).logradouro 
                    , tb.numero         = est_cliente(i).numero 
                    , tb.bairro         = est_cliente(i).bairro     
                    , tb.cidade         = est_cliente(i).cidade     
                    , tb.uf             = est_cliente(i).uf         
                    , tb.ativo          = est_cliente(i).ativo      
                    , tb.dt_atualizacao = sysdate    
                where tb.id_cliente = est_cliente(i).id_cliente ;  
            exception
               when others then
                  vv_msg_erro := 'Erro ao alterar cliente. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM; 
                  vn_cd_erro  := -20002;
                  raise_application_error(vn_cd_erro,vv_msg_erro);                  
            end;

         end loop;
      
      end if;

   EXCEPTION
      when others then
         if vv_msg_erro is null then
            vv_msg_erro := 'Erro nao tratado pelo programa. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;
            vn_cd_erro  := -20000;
         end if;
         
         raise_application_error(vn_cd_erro,vv_msg_erro);
         
   END PRC_ALTERAR_CLIENTE;   

   /*
   ____________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   ____________________________________________________________________________________________
   Definicão........: Procedimento criado para deletar informacões na tabela tb_cliente
   ____________________________________________________________________________________________
   */
   PROCEDURE PRC_DELETAR_CLIENTE ( est_cliente      in out nocopy t_tab_rec_cliente 
                                 ) IS

   BEGIN
     
      if est_cliente.count > 0 then

         for i in est_cliente.first .. est_cliente.last
         loop
            
            begin
               delete tb_cliente tb                  
                where tb.id_cliente = est_cliente(i).id_cliente ;  
            exception
               when others then
                  vv_msg_erro := 'Erro ao excluir cliente. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;
                  vn_cd_erro  := -20002;
                  raise_application_error(vn_cd_erro,vv_msg_erro);                  
            end;

         end loop;
      
      end if;
     
   EXCEPTION
      when others then
         if vv_msg_erro is null then
            vv_msg_erro := 'Erro nao tratado pelo programa. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;
            vn_cd_erro  := -20000;
         end if;
         
         raise_application_error(vn_cd_erro,vv_msg_erro);

   END PRC_DELETAR_CLIENTE;
   
   /*
   _______________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   _______________________________________________________________________________________________
   Definicão........: Procedimento criado para realizar o lock em um registro da tabela tb_cliente
   _______________________________________________________________________________________________
   */
   PROCEDURE PRC_LOCK_REG_CLIENTE ( est_cliente      in out nocopy t_tab_rec_cliente 
                                  ) IS
      vn_lock number;
      
   BEGIN     
      
      if est_cliente.count > 0 then

         for i in est_cliente.first .. est_cliente.last
         loop
            
            begin

               select 1
                 into vn_lock
                 from tb_cliente tb
                where tb.id_cliente = est_cliente(i).id_cliente
                  for update of tb.id_cliente nowait ;

            exception
               when no_data_found then
                  null;
               when others then
                  vv_msg_erro := 'Registro esta em uso por outro usuario. Verifique!';
                  vn_cd_erro  := -20002;
                  raise_application_error(vn_cd_erro,vv_msg_erro);
            end;

         end loop;
      
      end if;

   EXCEPTION
      when others then
         if vv_msg_erro is null then
            vv_msg_erro := 'Erro nao tratado pelo programa. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;
            vn_cd_erro  := -20000;
         end if;
         
         raise_application_error(vn_cd_erro,vv_msg_erro);
         
   END PRC_LOCK_REG_CLIENTE;   
      
   /*
   _______________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   _______________________________________________________________________________________________
   Definicão........: Procedimento criado para listar as unidades federativas
   _______________________________________________________________________________________________
   */
   PROCEDURE PRC_LOV_UF ( st_lov out nocopy dbms_sql.varchar2_table ) is
   BEGIN
      
      if vt_uf.count = 0 then
         pkg_cliente.prc_carrega_uf;
      end if;

      st_lov := vt_uf;
      
   EXCEPTION
      when others then
         if vv_msg_erro is null then
            vv_msg_erro := 'Erro nao tratado pelo programa. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;
            vn_cd_erro  := -20000;
         end if;
         
         raise_application_error(vn_cd_erro,vv_msg_erro);         
   END PRC_LOV_UF;
   
   /*
   _______________________________________________________________________________________________
   Desenvolvido por.: Leonardo Godas
   Data.............: 04/01/2026
   _______________________________________________________________________________________________
   Definicão........: Procedimento criada para validar registros do forms
   _______________________________________________________________________________________________
   */
   PROCEDURE PRC_VALIDA ( ev_bloco in varchar2
                        , ev_campo in varchar2
                        , ev_valor in varchar2
                        ) IS
      BEGIN    
         
         if ev_bloco = 'BL_CLIENTE' then
            
            if ev_campo = 'NOME' then
               
               if ev_valor is null then
                  vv_msg_erro := 'Campo "Nome" nao pode ser nulo. Verifique!';
                  vn_cd_erro  := -20002;
                  raise_application_error(vn_cd_erro,vv_msg_erro);
               end if;
               
            elsif ev_campo = 'EMAIL' then
               
               if ev_valor is null then
                  vv_msg_erro := 'Campo "E-mail" nao pode ser nulo. Verifique!';
                  vn_cd_erro  := -20002;
                  raise_application_error(vn_cd_erro,vv_msg_erro);
               end if;
               
               if pkg_cliente.fn_email_valido( ev_valor ) = 0 then
                  vv_msg_erro := 'E-mail informado nao e valido. Verifique!';
                  vn_cd_erro  := -20002;
                  raise_application_error(vn_cd_erro,vv_msg_erro);
               end if;
               
            elsif ev_campo = 'CEP' then

               if pkg_cliente.fn_cep_valido( ev_valor ) = 0 then
                  vv_msg_erro := 'CEP informado nao e valido. Verifique!';
                  vn_cd_erro  := -20002;
                  raise_application_error(vn_cd_erro,vv_msg_erro);
               end if;
            
            elsif ev_campo = 'UF' then
               
               --if not vt_uf.exists(ev_valor) then
               --   vv_msg_erro := 'UF informada nao e valida. Verifique!';
               --   vn_cd_erro  := -20002;
               --   raise_application_error(vn_cd_erro,vv_msg_erro);
               --end if;
               null;
               
            end if;
            
         end if;
      
      EXCEPTION
      when others then
         if vv_msg_erro is null then
            vv_msg_erro := 'Erro nao tratado pelo programa. Favor encaminhe o erro para o responsavel pelo sistema. ' || SQLERRM;
            vn_cd_erro  := -20000;
         end if;
         
         raise_application_error(vn_cd_erro,vv_msg_erro);
         
   END PRC_VALIDA;

END PKG_CLIENTE;
/