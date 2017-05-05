		<span class="searchbox" style="padding-left: 10px;">
			<input class="" type="text" id="searchbox" placeholder="search">
			<span class="clear-input" id="searchbox_clear" title="Clear search">×</span>
		</span>

<script type="text/javascript">
	$(document).ready( function () {
		//$("#searchbox").bind("keyup search input paste cut", function(event) {
		$("#searchbox").on("keyup", function(event) {
			if (event.keyCode == 13) {
				// Да е с параметър true (по подразбиране), за да опресни и номерата на страниците
				// search( input [, regex[ , smart[ , caseInsen ]]] )
				oTable.search($(this).val(), false, false).draw();
			}
		});
		$("#searchbox_clear").on("click", function(event) {
			$("#searchbox").val('');
			oTable.search('').draw();
		});
	}); // $(document).ready
</script>
