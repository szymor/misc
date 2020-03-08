int face_distance()
// distance to target, positive when faced towards it
// 80 pixels may be considered as a maximum distance allowing close combat
{
    return ( self.x - target.x ) * ( 2 * ( self.facing ? 1 : 0 ) - 1 );
}

bool dist_between( int min, int max )
// checks whether distance to target is within bounds
{
    return ( ( face_distance() < max ) && ( face_distance() > min ) );
}

bool z_axis_dist( int dist )
{
    return ( abs( self.z - target.z ) <= dist ) ? true : false;
}

bool same_z_axis()
// checks whether our character is on the same z axis as the opponent
{
    return ( abs( self.z - target.z ) <= 8 ) ? true : false;
}

int ego()
{
    if( ( self.frame >= 261 ) && ( self.frame <= 269 ) )
    {
        if( ( target.state == 13 ) || ( target.state == 14 ) )
        {
            D();
            return 0;
        }
        if( ( self.frame == 269 ) && ( target.y == 0 ) )
        {
            D();
            return 0;
        }
        return 1;
    }
    else
    {
        // grab the opponent if he is prone to :)
        if( dist_between(40,80) && ( target.state == 16 ) && same_z_axis() )
        {
            if( self.facing )
                left();
            else
                right();
            return 0;
        }

        // while grabbing
        if( ( self.state == 9 ) && ( target.state == 10 ) && same_z_axis() && ( self.ctimer < 75 ) && ( self.mp > 30 ) )
        {
            DJA();
            return 0;
        }

        if( dist_between(10,50) && ( target.state == 3 ) && same_z_axis() && ( self.mp > 30 ) )
        {
            DJA();
            J();
            return 0;
        }

        if( dist_between(25,80) && ( target.state < 3 ) && same_z_axis() && ( self.mp > 60 ) )
        {
            DdA();
            return 0;
        }

        if( dist_between(150,500) && same_z_axis() && ( self.mp > 200 ) )
        {
            if( self.facing )
            {
                DlA();
                A();
            }
            else
            {
                DrA();
                A();
            }
            return 0;
        }

        if( dist_between(-200,200) && z_axis_dist(70) && ( self.mp > 400 ) && ( target.state != 13 ) && ( target.state != 14 ) )
        {
            DuJ();
            return 1;
        }
    }
    return 0;
}
