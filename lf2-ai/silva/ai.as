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

    // mid and long range

    if( self.frame == 235 )
    {
        if( dist_between(400,700) && ( self.mp > 350 ) )
            D();
        if( dist_between(150,400) && (self.mp > 200) )
            J();
    }

    if( dist_between(400,700) && ( self.mp > 350 ) )
    {
        if( self.facing )
        {
            DlA();
        }
        else
        {
            DrA();
        }
        return 0;
    }

    if( dist_between(150,400) && same_z_axis() && ( self.mp > 70 ) && ( target.state < 3 ) )
    {
        if( self.facing )
        {
            DlA();
        }
        else
        {
            DrA();
        }
        return 0;
    }

    // close range combos

    if( self.frame == 257 )
    {
        if( target.state == 12 )
            J();
        if( target.y == 0 )
            A();
        return 0;
    }

    if( self.frame == 75 )
    {
        J();
        return 0;
    }

    if( dist_between(10,60) && ( target.state < 3 ) && same_z_axis() && ( self.mp > 50 ) )
    {
        DdA();
        return 0;
    }

    return 0;
}
