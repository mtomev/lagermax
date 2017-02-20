{extends file="layout.tpl"}
{block name=content}
<div id="main">
	<div id="nomedit" class="white-popup-block">
		<div class="header">{#menu_config#}</div>

		<div id="edit" class="nomedit-edit">
			<div class="table-row">
				<div class="table-cell-label">{#config_aviso_days_forecast#}</div>
				<div class="table-cell">
					<input id="config_aviso_days_forecast" class="number-small mandatory" data-type="Count" type="text" name="config_aviso_days_forecast" value="{$data.config_aviso_days_forecast}">
				</div>
			</div>

			<div class="table-row">
				<div class="table-cell-label">{#config_aviso_until_time#}</div>
				<div class="table-cell">
					<input id="config_aviso_until_time" class="time mandatory" data-type="Time" type="text" name="config_aviso_until_time" value="{$data.config_aviso_until_time}">
				</div>
			</div>
		</div> {* div id="edit" *}

		<div class="row-button">
			{if $smarty.session.userdata.grants.config_edit == '1'}
			<button class="save_button" id="save_button"><span>{#btn_Save#}</span></button>
			{/if}
			<button class="cancel_button" id="cancel_button"><span>{#btn_Cancel#}</span></button>
		</div>
	</div>
</div>

<script type="text/javascript">
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

		// Автоматично разпъване на textarea
		$('textarea', '#edit').each(function () {
			textarea_auto_height(this);
		});
	});

	$('#save_button', '#nomedit').click (function () {
		$('#edit .isRequired').each( function() {
			$(this).removeClass('isRequired');
		});
		if (!EsCon.check_mandatory($('#edit .mandatory'))) return false;

		var ser_data = EsCon.serialize($('#edit :input'));
		
		jQuery.post('/main_menu/config_save', ser_data, function (result) {
			if (result) 
				fnShowErrorMessage('', result);
			else
				window.location.href = '/configuration';
		});
	});

	$('#cancel_button').click (function () {
		window.location.href = '/configuration';
	});
</script>
{/block}