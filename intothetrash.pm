package LANraragi::Plugin::Scripts::intothetrash;

use LANraragi::Utils::Database; 
use LANraragi::Model::Category; 
use Mojo::JSON qw(decode_json);

#Meta-information about your plugin.
sub plugin_info {

    return (
        #Standard metadata
        name        => "Purge Unwanted Archives",
        type        => "script",
        namespace   => "intothetrash",
        author      => "Anzio_Supreme",
        version     => "0.0.22",
        description => "Just Fuck my Shit Up!",
    );

}

# Mandatory function to be implemented by your script
sub run_script {
 shift;
  my $purged = 0;

	for ( my $i = 1; $i < 10; $i++ ) {
## Change SET_XXXXXXXXXX to whatever the category is 
		%category = LANraragi::Model::Category::get_category("SET_1606554663");

		  if (%category) {

			@cat_archives = @{ decode_json( $category{archives} ) };    
			# category archives, if it's a standard category
    
			foreach my $id (@cat_archives) {
				LANraragi::Utils::Database::delete_archive($id);
				$purged++;
			}

		  }	
	}
		return (
			Purged_Books	=>	$purged
			#this function does not work properly! It will dump random number instead!
		);
}
1;
