# define additional plugins for a range/group of Jenkins instances
{
  # https://bugs.eclipse.org/bugs/show_bug.cgi?id=575369
  additionalPlugins(projectFullName): if (std.startsWith(projectFullName, "ee4j")) then ["jacoco"] else [],
}