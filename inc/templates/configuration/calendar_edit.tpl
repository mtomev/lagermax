<div id="nomedit" class="white-popup-block">
	<div class="header">
	{if $data.id > 0}{#Edit#}{else}{#Add#}{/if} {#table_calendar#}
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#calendar_date#}</div>
			<div class="table-cell">
				<input id="calendar_date" class="date mandatory" data-type="Date" type="text" name="calendar_date" value="{$data.calendar_date}">
			</div>
		</div>
		
		<div class="table-row">
			<div class="table-cell-label"></div>
			<div class="table-cell">
				<label>
				<input class="checkbox" type="radio" name="calendar_is_working_day" value="2" {if $data.calendar_is_working_day == '2'}checked{/if}>&nbsp;{#calendar_is_working_day_2#}
				</label>
				<label>
				<input class="checkbox" type="radio" name="calendar_is_working_day" value="1" style="margin-left: 10px;" {if $data.calendar_is_working_day == '1'}checked{/if}>&nbsp;{#calendar_is_working_day_1#}
				</label>
			</div>
		</div>
	</div>

	{include file='configuration/btn_save_delete.tpl'}
</div>

<script type="text/javascript">
	$(document).ready( function () {
		// Автоматично разпъване на textarea
		$('textarea', '#nomedit').each(function () {
			textarea_auto_height(this);
		});
	}); // $(document).ready

	function callbackSave() {
		return true;
	}

</script>
