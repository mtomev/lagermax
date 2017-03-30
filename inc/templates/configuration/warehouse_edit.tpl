<div id="nomedit" class="white-popup-block">
	<div class="header">
	{if $data.id > 0}{#Edit#}{else}{#Add#}{/if} {#table_warehouse#}
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#table_w_group#}</div>
			<div class="table-cell">
				<select id="w_group_id" name="w_group_id" class="text mandatory"> 
					{html_options options=$select_w_group selected=$data.w_group_id}
				</select>
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#warehouse_name#}</div>
			<div class="table-cell">
				<input id="warehouse_name" class="text mandatory" type="text" maxlength="{$data.field_width.warehouse_name}" name="warehouse_name" value="{$data.warehouse_name}">
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#warehouse_code#}</div>
			<div class="table-cell">
				<input id="warehouse_code" class="text10 mandatory" type="text" maxlength="{$data.field_width.warehouse_code}" name="warehouse_code" value="{$data.warehouse_code}">
			</div>
		</div>
		
	<div style="float: left;">
		<div class="table-row">
			<div class="table-cell-label">{#w_start_time#}</div>
			<div class="table-cell">
				<input id="w_start_time" class="time mandatory calc_timeslots" data-type="Time" type="text" name="w_start_time" value="{$data.w_start_time}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#w_end_time#}</div>
			<div class="table-cell">
				<input id="w_end_time" class="time mandatory calc_timeslots" data-type="Time" type="text" name="w_end_time" value="{$data.w_end_time}">
			</div>
		</div>

		<div class="table-row">
			<div class="table-cell-label">{#w_interval#}</div>
			<div class="table-cell">
				<input id="w_interval" class="number-small mandatory calc_timeslots" data-type="Count" type="text" name="w_interval" value="{$data.w_interval}">
			</div>
		</div>
		{*
		<div class="table-row">
			<div class="table-cell-label">{#w_count#}</div>
			<div class="table-cell">
				<input id="w_count" class="number-small mandatory" data-type="Count" type="text" name="w_count" value="{$data.w_count}">
			</div>
		</div>
		*}
		<div class="table-row">
			<div class="table-cell-label">{#w_max_pallet#}</div>
			<div class="table-cell">
				<input id="w_max_pallet" class="number-small mandatory" data-type="Count" type="text" name="w_max_pallet" value="{$data.w_max_pallet}">
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#w_pack2pallet#}</div>
			<div class="table-cell">
				<input id="w_pack2pallet" class="number-small mandatory" data-type="Count" type="text" name="w_pack2pallet" value="{$data.w_pack2pallet}">
			</div>
		</div>
	</div>

	{* Таблица с часовите слотове *}
	<div id="timeslots" style="float:left; margin-left:40px; max-height: 200px;overflow-y: auto;width: 80px;border: 1px solid transparent;border-color: #ccc;padding-left: 10px;">
	</div>

	<div style="clear: left;">
		{*
		<div class="table-row">
			<div class="table-cell-label">{#warehouse_template#}</div>
			<div class="table-cell">
				<input id="warehouse_template" class="text10 mandatory" type="text" maxlength="{$data.field_width.warehouse_template}" name="warehouse_template" value="{$data.warehouse_template}">
			</div>
		</div>
		*}
		<input type="hidden" id="warehouse_template" name="warehouse_template" value="{$data.warehouse_template}">

		<div class="table-row">
			<div class="table-cell-label">{#warehouse_type#}</div>
			<div class="table-cell">
				<select id="warehouse_type" name="warehouse_type" class="text10 mandatory"> 
					{html_options options=$select_warehouse_type selected=$data.warehouse_type}
				</select>
			</div>
		</div>
		
		<div class="table-row">
			<div class="table-cell-label"></div>
			<div class="table-cell">
				<input id="is_active" class="" type="checkbox" name="is_active" value="1" {if $data.is_active}checked="checked"{/if}>&nbsp;{#is_active#}
			</div>
		</div>
	</div>

	</div>

	{include file='configuration/btn_save_delete.tpl'}
</div>

<script type="text/javascript">
	// Пресмятане на часовите слотове
	$('.calc_timeslots', '#nomedit').change(function () {
		var org_id = $('#org_id', '#nomedit').val();
		//try {
			var curr_time = new Date();
			var t = $('#w_start_time', '#nomedit').val();
			curr_time.setUTCHours(t.substr(0,2));
			curr_time.setUTCMinutes(t.substr(3,2), 0, 0);

			var w_end_time = new Date();
			t = $('#w_end_time', '#nomedit').val();
			w_end_time.setUTCHours(t.substr(0,2));
			w_end_time.setUTCMinutes(t.substr(3,2), 0, 0);

			var w_interval = $('#w_interval', '#nomedit').val() * 60 * 1000;
			var timeslots = '';
			if (w_interval)
				while (curr_time <= w_end_time) {
					t = curr_time.toISOString().substr(11, 5);
					timeslots += t+'<br>';
					curr_time.setTime(curr_time.getTime() + w_interval);
				}
			$('#timeslots', '#nomedit').html(timeslots);
		/*}
		catch(err) {
			console.log(err);
			return false;
		}*/
	});

	$(document).ready( function () {
		$('#w_start_time', '#nomedit').trigger('change');

		// Автоматично разпъване на textarea
		$('textarea', '#nomedit').each(function () {
			textarea_auto_height(this);
		});
	}); // $(document).ready

	function callbackSave() {
		return true;
	}

</script>
