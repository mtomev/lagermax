	<div class="status-line">
		<span>cr: {$data.cr_user_name}, <span class="cr_date">{$data.cr_date}</span> / mo: {$data.mo_user_name}, <span class="cr_date">{$data.mo_date}</span></span>
	</div>
<script type="text/javascript">
	$(document).ready( function () {
		$('.status-line span.cr_date').each(function() {
			var d = EsCon.formatCRDate($(this).text());
			$(this).removeClass('cr_date');
			$(this).html(d);
		});
});
</script>
