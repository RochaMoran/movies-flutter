import 'package:flutter/material.dart';
import 'package:movies/models/movie.dart';

class MovieSliderScreen extends StatefulWidget {
  final String? title;
  final List<Movie> movies;
  final Function onNextPage;

  const MovieSliderScreen({Key? key, this.title, required this.movies, required this.onNextPage}) : super(key: key);

  @override
  State<MovieSliderScreen> createState() => _MovieSliderScreenState();
}

class _MovieSliderScreenState extends State<MovieSliderScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300) {
        widget.onNextPage();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Column(
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                ),
              )
            ),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.movies.length,
              itemBuilder: (_, int i) => _MoviePoster(movie: widget.movies[i])
            ),
          )
        ],
      ),
    );
  }
}


class _MoviePoster extends StatelessWidget {
  final Movie movie;
  const _MoviePoster({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    movie.heroId = 'slider-${movie.id}';

    return Container(
      width: 140,
      height: 150,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, 'details', arguments: movie),
            child: Hero(
              tag: movie.heroId!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  placeholder: const AssetImage('assets/no-image.jpg'), 
                  image: NetworkImage(movie.fullPosterImg), 
                  fit: BoxFit.cover, 
                  width: 140, 
                  height: 170
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            movie.title, 
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}