<div id="nomedit" class="white-popup-block">

	<div class="header">
		<span>{#Add#} {#table_aviso#}</span>
	</div>

	<div id="edit" class="nomedit-edit">
		<div class="table-row">
			<div class="table-cell-label">{#w_group_name#}</div>
			<div class="table-cell">
				<select id="w_group_id" name="w_group_id" class="text30 mandatory"> 
					{html_options options=$select_w_group selected=$data.w_group_id}
				</select>
			</div>
		</div>
		<div class="table-row">
			<div class="table-cell-label">{#warehouse_name#}</div>
			<div class="table-cell">
				<select id="warehouse_id" name="warehouse_id" class="text mandatory"> 
					{html_options options=$select_warehouse selected=$data.warehouse_id}
				</select>
			</div>
		</div>
	</div>

	<div class="row-button">
		<button class="save_button" id="save_button"><span>{#btn_Next#}</span></button>
		<button class="cancel_button" id="cancel_button"><span>{#btn_Cancel#}</span></button>
	</div>

</div>

<script type="text/javascript">
	EsCon.set_mandatory($('#edit .mandatory'));

	// При смяна на w_group_id, да изтегля списъка от складовете
	// w_group_id, aviso_date, aviso_time, брой палети
	$('#w_group_id', '#nomedit').change(function () {
		var w_group_id = EsCon.getParsedVal($('#w_group_id', '#nomedit'));
		$.ajax({
			url: "/aviso/get_w_group_id_warehouse/"+w_group_id,
			method: "POST",
			success: function (result) {
				try {
					var data = JSON.parse(result)
				}
				catch(err) {
					console.log(err);
					fnShowErrorMessage('', result);
					return false;
				}
				try {
					var html = generate_select_option_2D(data, 0, true);
					$('#warehouse_id', '#nomedit').empty().append(html);
				}
				catch(err) {
					console.log(result);
					fnShowErrorMessage('', err);
					return false;
				}
				EsCon.set_mandatory($('#nomedit #warehouse_id.mandatory'));
			} // success
		});
	});

	$('#save_button').click (function () {
		if (!EsCon.check_mandatory($('#nomedit .mandatory'))) return false;

		var url = '/aviso/aviso_edit/0/'+$('#warehouse_id').val();
		//($.magnificPopup.instance).close();
		window.location.href = url;
	});
	$('#cancel_button', '#nomedit').click (function () {
		($.magnificPopup.instance).close();
	});
</script>