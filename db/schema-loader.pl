{
    schema_class => "SearchAd::Schema",
    connect_info =>
        { dsn => "dbi:SQLite:db/searchad.db", on_connect_do => 'PRAGMA foreign_keys = ON', sqlite_unicode => 1, },
    loader_options => {
        dump_directory            => 'lib',
        naming                    => { ALL => 'v8' },
        rel_name_map              => { adkeywords_2s => 'adkeywordss' },
        skip_load_external        => 1,
        relationships             => 1,
        col_collision_map         => 'column_%s',
        result_base_class         => 'SearchAd::Schema::Base',
        overwrite_modifications   => 1,
        datetime_undef_if_invalid => 1,
        custom_column_info        => sub {
            my ( $table, $column_name, $column_info ) = @_;
            if ( $column_name eq 'create_date' ) {
                return { %$column_info, set_on_create => 1, inflate_datetime => 'epoch', };
            }
            elsif ( $column_name eq 'update_date' ) {
                return { %$column_info, set_on_create => 1, set_on_update => 1, inflate_datetime => 'epoch', };
            }
        },
    },
}
