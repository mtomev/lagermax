{* Това се добавя само към .tpl корекция на Номенклатурите в /configuration/
*}

	<div class="row-button">
	{if $data.allow_edit}
		<button class="save_button" id="save_button"><span>{#btn_Save#}</span></button>
	{/if}
		<span>id:{$data.id}</span>
		<button class="cancel_button" id="cancel_button"><span>{#btn_Cancel#}</span></button>
	{if $data.allow_delete}
		<button class="delete_button" id="delete_button"><span>{#btn_Delete#}</span></button>
	{/if}
	</div>
	{include file='main_menu/status_line.tpl'}

<script type="text/javascript">
	{assign var="nomen_menu" value="menu_{$smarty.session.table_edit}"}

	$(document).ready( function () {
		// Група от общи за всички номенклатури
		EsCon.set_datepicker();
		EsCon.set_number_val($('.number, .number-small, .time', '#edit'));
		// Да сложим attr placeholder на всички с .mandatory
		EsCon.set_mandatory($('#edit .mandatory'));

		$('.number, .number-small, .date, .time', '#edit').on('focus', EsCon.inputEvent.focusin);
		$('.number, .number-small, .date, .time', '#edit').on('change', EsCon.inputEvent.change);
		$('.number, .number-small', '#edit').on('keydown', EsCon.inputEvent.keydown);
		// край на Група от общи за всички номенклатури
	});


	// Когато отворя за корекция друга номенклатура, без да съм рефрешвал страницата, те тези функции все още същуствуват !!!
	// Затова винаги слагам едни празни функции, които, ако трябва, във всяка конкретна .tpl ще бъдат предефинирани
	function callbackRequired() { return true; }
	function callbackSave() { return true; }
	function callbackSaveSerialize() { 
		//return $('#edit :input').serialize();
		return EsCon.serialize($('#edit :input'));
	}
	function callbackSaveError() { }

	function saveData(closePopup, callBack) { 
		$('#edit .isRequired').each( function() {
			$(this).removeClass('isRequired');
		});
		if (typeof(callbackRequired) == 'function') {
			if (!callbackRequired()) return false;
		}
		if (!EsCon.check_mandatory($('#edit .mandatory'))) return false;

		if (typeof callbackSave == 'function') {
			if (!callbackSave()) return false;
		}
		var ser_data;
		if (typeof callbackSaveSerialize == 'function')
			ser_data = callbackSaveSerialize();
		else
			ser_data = $('#edit :input').serialize();

		jQuery.post('/configuration/{$smarty.session.table_edit}_save/{$data.id}', ser_data, function (result) {
			if (result) {
				if (typeof(callbackSaveError) == 'function') callbackSaveError();
				fnShowErrorMessage('{#title_error#}', result);
			} else {
				if (typeof(fancyboxSaved) == 'function') fancyboxSaved();
				if (typeof(callBack) == 'function') callBack();
				if (closePopup)
					($.magnificPopup.instance).close();
			}
		});
	}
	$('#save_button', '#nomedit').click (function () {
		saveData(true);
	});

	$('#cancel_button', '#nomedit').click (function () {
		($.magnificPopup.instance).close();
	});
	$('#delete_button', '#nomedit').click (function () {
		fnDeleteDialog('/configuration/{$smarty.session.table_edit}_delete/{$data.id}', '{$smarty.config.$nomen_menu}');
	});

</script>