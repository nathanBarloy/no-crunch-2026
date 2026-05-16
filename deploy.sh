# Configure paths
build_dir="build"
zip_name="moleom"
itchio_repo="baloox/moleom"

# Get the right deploy targets
if [ $# -eq 0 ]
then
	declare -a dest_arr=( "web" "linux" "windows")
else
	declare -a dest_arr=( "$@" )
fi

# Zip all targets
for dest in "${dest_arr[@]}"
do
	echo "Creating $dest zip"
	zip "$build_dir/$dest/$zip_name-$dest.zip" -j $build_dir/$dest/*.*
done

# Deploy all targets to itch.io
for dest in "${dest_arr[@]}"
do
        echo "Deploying $dest gamefile"
	butler push "$build_dir/$dest/$zip_name-$dest.zip" $itchio_repo:$dest
done

