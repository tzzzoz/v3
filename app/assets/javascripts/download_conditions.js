function valid_form(p, r) {
    var valide = parseInt($('#form_valide').val()) + 1;
    var pcount = $('#prov_count').val();
    $('#form_valide').attr('value', valide);
    if (r == 0) { $('#prov_'+p).attr('checked', false); }
    $('#provider_form_'+p).hide();
    if (valide == pcount) {
         var ids = '';
         $("#valid_conditions :input:checkbox").each(function() {
             if ($(this).is(':checked')) { ids += $(this).val(); }
         });
        setTimeout(function() { location="/downloads/?condition_checked=1&definition=HD"+ ids; },1000);
    }
}

function checkEdition() {
    var itst = 0;
    if ($(".verif_edition:input:checkbox:checked").size() == 0) { alert('Vous devez choisir un support de publication'); itst = 1; }
    if (($(".verif_edition:input:checkbox:checked").size() > 1) && ($(".illu_video:input:checkbox:checked").size() == 0)) { alert('Vous ne devez choisir qu\'un seul support de publication'); itst = 1;return false; }
    $('.verif_edition:input:checkbox:checked').each(function() {
       switch (this.name) {
        case 'edition':
          if (!($('#title_edition').val())) { alert('Le titre du livre est obligatoire'); itst = 1; }
          var edat = $('#edition1').val() + "/" + $('#edition2').val() + "/" + $('#edition3').val();
          $('#publication_edition').attr('value', edat);
          if ('//'==($('#publication_edition').val())) { alert('La date de publication est obligatoire'); itst = 1; }
          if (!($('.exemplaires').val())) { alert('Le nombre d\'exemplaires est obligatoire'); itst = 1; }
          if ($('.verif_diffusion:input:radio:checked').size() == 0) { alert('La diffusion est obligatoire'); itst = 1;}
          break;
        case 'presse':
          if (!($('#title_presse').val())) { alert('Le titre du périodique est obligatoire'); itst = 1; }
          if (!($('#num_presse').val())) { alert('Le numéro du périodique est obligatoire'+' - '+$('#num_presse').val()); itst = 1; }
          if (!($('.exemplaires').val())) { alert('Le nombre d\'exemplaires est obligatoire'); itst = 1; }
          if ($('.verif_diffusion:input:radio:checked').size() == 0) { alert('La diffusion est obligatoire'); itst = 1;}
          break;
        case 'pub_presse':
          if (!($('#title_pub_presse').val())) { alert('Le titre du périodique est obligatoire'); itst = 1; }
          if (!($('#num_pub_presse').val())) { alert('Le numéro du périodique est obligatoire'); itst = 1; }
          if (!($('.exemplaires').val())) { alert('Le nombre d\'exemplaires est obligatoire'); itst = 1; }
          if ($('.verif_diffusion:input:radio:checked').size() == 0) { alert('La diffusion est obligatoire'); itst = 1;}
          break;
        case 'tv':
          if (!($('#emission_tv').val())) { alert('Le titre de l\'émission est obligatoire'); itst = 1; }
          var tvdat = $('#tv1').val() + "/" + $('#tv2').val() + "/" + $('#tv3').val();
          $('#diffusion_tv').attr('value', tvdat);
          if ('//'==($('#diffusion_tv').val())) { alert('La date de première diffusion est obligatoire'); itst = 1; }
          break;
        case 'cinema':
          if (!($('#film').val())) { alert('Le titre du film est obligatoire'); itst = 1; }
          var cinedat = $('#jour_cinema').val() + "/" + $('#mois_cinema').val() + "/" + $('#annee_cinema').val();
          $('#diffusion_cinema').attr('value', cinedat);
          if ('//'==($('#diffusion_cinema').val())) { alert('La date de première diffusion est obligatoire'); itst = 1; }
          break;
        case 'video':
          if (!($('.exemplaires').val())) { alert('Le nombre d\'exemplaires est obligatoire'); itst = 1; }
          if ($('.verif_diffusion:input:radio:checked').size() == 0) { alert('La diffusion est obligatoire'); itst = 1;}
          break;
        /*case 'internet':
          break;
        case 'publicitaire':
          break;
        case 'autre':
          if (!($('#other').val())) { alert('Merci de préciser'); itst = 1; }
          break;*/
       }
    });
    if (!($('input[name="nclient"]').val()) && !($('input[name="legal_name"]').val())) {
       alert('Vous devez soit entrer votre no de client, soit entrer votre raison sociale');
       itst = 1;
    }
    //if (!($('input[name="nclient"]').val()) && !($('input[name="email"]').val())) { alert('email obligatoire'); itst = 1; }
    if (!($('input[name="nclient"]').val()) && !($('input[name="adresse"]').val())) { alert('adresse obligatoire'); itst = 1; }
    if (!($('input[name="nclient"]').val()) && !($('input[name="postal_code"]').val())) { alert('code postal obligatoire'); itst = 1; }
    if (!($('input[name="nclient"]').val()) && !($('input[name="city"]').val())) { alert('ville obligatoire'); itst = 1; }
    if (itst == 0) { return true; }
    else { return false; }
}

function enableBlock(nom,valeur) {
  $('.'+nom).each( function(){
      if (!valeur) { $(this).attr('disabled', 'disabled'); }
      else { $(this).removeAttr('disabled'); }
  })
}

function displayBlock(){
if ($('#liv_pag_pap').is(':checked') || $('#liv_pag_num').is(':checked') ||
      $('#per_pag_pap').is(':checked') || $('#per_pag_num').is(':checked') ||
      $('#pub_per_pag_pap').is(':checked') || $('#video').is(':checked')) {
      $('#group2').show();
      $('#group3').show(); }
  else {
      $('#group2').hide();
      $('#group3').hide(); }
}

function checkForm(p, r){
      if (r == 0) { valid_form(p,r); }
      else {
        if ($('#agrement').is(':checked')) {
           if (checkEdition()) {
               valid_form(p, r);
               $('#valid_conditions').submit();
           }
           else { return false; }
        }
     else {
          alert('Vous devez accepter les conditions d\'utilisation');
          return false;
        }
      }
}

function checkThis(wich,valtype,block_to_enable,val_enable,zone){
   var message='';
      if ((block_to_enable) && (val_enable!=null)) {enableBlock(block_to_enable,val_enable);}
   if( zone ){displayBlock();}
      if ( '' != wich.value ){
    switch(valtype){
	    case 'nomb':
		    if(isNaN(wich.value)){message='veuillez entrer un nombre';}
	        break;
	    case 'tva1':
		    if(!(isNaN(wich.value)) || wich.value.length!=2){message='veuillez entrer deux lettres';}
	        break;
	    case 'tva2':
		    if(wich.value.length!=11){message='veuillez entrer un texte valide';}
	        break;
	    case 'jour':
		    if(isNaN(wich.value) || wich.value>31){message='veuillez entrer un jour';}
	        break;
	    case 'mois':
		    if(isNaN(wich.value) || wich.value>12){message='veuillez entrer un mois';}
	        break;
	    case 'annee':
		    if(isNaN(wich.value) || wich.value.length!=4){message='sur 4 chiffres';}
	        break;
	    case 'chaine':
		    if(wich.value.length<4){message='veuillez entrer un texte valide';}
	        break;
	    case 'mail':
		    var filter  = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
		    if (!filter.test(wich.value)){message='veuillez entrer un email valide';}
	        break;
	    case 'checkb':
	        break;
    }
   }/*else{
    message='champ vide';
   }*/
   if (message){
          alert(message);
    document.getElementById('warn-'+wich.parentNode.id).firstChild.nodeValue=message;
    if(navigator.appName == "Microsoft Internet Explorer"){
	    manda=(wich.className=='manda')?1:0;
    }else{
	    manda=(wich.getAttribute('class')=='manda')?1:0;
    }
    if(manda){
	    document.getElementById('warn-'+wich.parentNode.id).firstChild.nodeValue+='\nce champ est obligatoire';
          }
   }else{
    document.getElementById('warn-'+wich.parentNode.id).firstChild.nodeValue='';
      }
}