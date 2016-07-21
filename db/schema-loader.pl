{
    schema_class => "SearchAd::Schema",
    connect_info => {
        dsn  => $ENV{SEARCHAD_DATABASE_DSN}  || "dbi:mysql:searchad:127.0.0.1",
        user => $ENV{SEARCHAD_DATABASE_USER} || 'searchad',
        pass => $ENV{SEARCHAD_DATABASE_PASS} // 'searchad',
        opts => {
            quote_char        => q{`},
            mysql_enable_utf8 => 1,
            on_connect_do     => 'SET NAMES utf8',
            RaiseError        => 1,
            AutoCommit        => 1,
        },
    },
    loader_options => {
        dump_directory            => 'lib',
        naming                    => { ALL => 'v8' },
        skip_load_external        => 1,
        relationships             => 1,
        col_collision_map         => 'column_%s',
        result_base_class         => 'SearchAd::Schema::Base',
        overwrite_modifications   => 1,
        datetime_undef_if_invalid => 1,
        custom_column_info        => sub {
            my ( $table, $column_name, $column_info ) = @_;
            if ( $column_name eq 'create_date' ) {
                return {
                    %$column_info,
                    set_on_create    => 1,
                    inflate_datetime => 1,
                };
            }
            elsif ( $column_name eq 'update_date' ) {
                return {
                    %$column_info,
                    set_on_create    => 1,
                    set_on_update    => 1,
                    inflate_datetime => 1,
                };
            }
        },
    },
}
